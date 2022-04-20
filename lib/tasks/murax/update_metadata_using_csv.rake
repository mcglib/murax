# frozen_string_literal: true

require 'active_record'
require 'csv'

namespace :murax do
  desc 'Update metadata for specified workids using data provided in a CSV file.'
  task :update_metadata_using_csv, %i[csv_file user_email] => :environment do |_task, args|
    if args.count < 2
      puts
      puts 'Usage: bundle exec rake murax:update_metadata_using_csv["<csv-filename>,<notification-email-recipient>"]'
      puts '       The task expects to find the csv file in the tmp directory'
      exit
    end
    @user_email = args.user_email
    csv_file = args.csv_file

    begin
      start_time = Time.now
      datetime_today = Time.now.strftime('%Y%m%d-%H%M%S')
      @logger = ActiveSupport::Logger.new("log/update_metadata_using_csv-#{datetime_today}.log")
      @logger.info "Task started at #{start_time}"

      csvfile_path = File.join Rails.root, 'tmp', csv_file
      tmp_dir = File.join Rails.root, 'tmp'
      if File.file?(csvfile_path)
        process_csv(csvfile_path)
      else
        msg = "Can't find #{csv_file} in #{tmp_dir} directory."
        @logger.warn msg
        puts "bye - #{msg}"
        exit
      end
      # Send a notification email that the work is done
      send_notification_email(@user_email) if @user_email.present?
    
    rescue ArgumentError => e
        msg = "Missing an argument #{e}"
        @logger.warn msg
        puts "bye - #{msg}"
        exit
    rescue StandardError => e
        msg = "A standard error occured. Error was #{e}"
        @logger.warn msg
        puts "bye - #{msg}"
        exit
    ensure
        end_time = Time.now
        @logger.info "Task ended at #{end_time}"
        puts "Log available at : #{@logger}"
        #csv_file.close
        #log_file.close
    end


  end
end

def process_csv(filename)
  # Read the csv file into the works_info array
  works_info = []
  headers = nil

  CSV.foreach(filename, headers: true, header_converters: :symbol) do |row|
    headers ||= row.headers
    works_info << row
  end
  # headers are giving me the list of fields
  # [:id, :title, :nested_ordered_creator, :contributor, :department, :faculty, :relation]
  
  # the action column
  actions = works_info[0]

  # remove the 2nd row
  works_info.shift
  works_info.each do |myrow|
    # We fix the row to a format that 
    # allows us to loop through all the fields in the row
    @logger.info "\n\nUpdating work id #: #{myrow[:id]}"
    update_work(myrow, myrow[:id], actions.to_h) unless myrow[:id] == 'Info'
  end
  @logger.info "Processed #{works_info.count} work ids"

end

def update_field(row, work_object)
  success  = true

  case row[:action].downcase
  when 'overwrite'
    @logger.info "Overwrite field #{row[:attribute_field]} for work id #{row[:id]} with #{row[:value]}"
    Murax::UpdateFieldWithValueService.new(row[:attribute_field], row[:value], row[:id], work_object).update
  when 'appended'
    @logger.info "Append to field #{row[:attribute_field]} for work id #{row[:id]} with #{row[:value]}"
    Murax::AppendFieldWithValueService.new(row[:attribute_field], row[:value], row[:id], work_object).append
  else
    @logger.error "You gave the action #{row[:action]} -- I have no idea what to do with that."
    success = false
  end

  success
end

def update_work(row, id, actions)
  success = true
  # convert my csv row to a hash 
  row_hash = row.to_h
  # loop through the hash to process each field
  work_object = ActiveFedora::Base.find(id)
  row_hash.map do | k,v|
    field_hash = {
      id: id,
      value: v,
      attribute_field: k,
      action: actions[k.to_sym]
    }
    update_field(field_hash, work_object)
  end

  success
end

def overwrite_field(fieldname, csv_value, work_id, work_object)
  @logger.info "Overwrite #{fieldname} for work id #{work_id} with #{csv_value}"
  puts "Overwrite #{fieldname} for work id #{work_id} with #{csv_value}"
  # Here we pass to the object service to update a single field

  if csv_value.include? '|'
    @logger.info "skip to multivalue function for #{fieldname}"
    overwrite_field_with_multivalue(fieldname, csv_value, work_id)
  else
    work_object = ActiveFedora::Base.find(work_id)
    if @nested_ordered_elements.key?(fieldname)

      # update of nested_ordered_elements is not working
      @logger.info "update a nested ordered element #{fieldname} with #{csv_value}"

      work_object[fieldname].clear
      # we have only one nested_ordered_element to create
      new_field = { index: '0', @nested_ordered_elements[fieldname].to_sym => csv_value }

      begin
        work_field = work_object[fieldname]
        work_field.build(new_field)
        work_object.save!
      rescue StandardError => e
        puts "error was #{e.message}"
        @logger.error "Error was #{e.message}"
      end
    elsif work_object[fieldname].instance_of? String
      @logger.info "update a string for the field #{fieldname}"
      work_object[fieldname] = csv_value
      work_object.save!
    else
      @logger.info 'update something which is not of type string'
      begin
        # this isn't working either
        new_field = []
        new_field << csv_value
        work_object[fieldname] = new_field
        work_object.save!
      rescue StandardError => e
        puts e.message
      end
    end
    @logger.info "work_object[#{fieldname}] is now #{work_object[fieldname]}"
  end
end


def append_to_field(fieldname, csv_value, work_id)
  # currently trying to append to multivalued fields will throw an error.  Should this be revised?
  @logger.info "append to field #{fieldname} for work id #{work_id} with #{csv_value}"
  if csv_value.include? '|'
    @logger.info "Cannot append multi-valued field (CSV contains: #{csv_value} for work id #{work_id})"
  else
    work_object = ActiveFedora::Base.find(work_id)
    work_value = work_object.attributes[fieldname]
    if @nested_ordered_elements.key?(fieldname)
      # update of nested_ordered_elements is not working
      if work_value.entries.count > 1
        @logger.info "work #{work_object['id']} has more than one #{fieldname} field. Cannot append."
      else
        # is it safe to assume that when there is only one element the index will always be 0??
        new_value = work_value.first[@nested_ordered_elements[fieldname]] + csv_value
        work_value = nil
        work_value << { index: '0', @nested_ordered_elements[fieldname].to_sym => new_value }
        work_object.save!
      end
    elsif work_value.instance_of? String
      # This is working! for both String and Array objects
      SearchAndReplaceInFieldOfObject.new(work_value, "#{work_value} #{csv_value}", fieldname, work_object)
    elsif work_value.count > 1
      @logger.info "work #{work_object['id']} has more than one #{fieldname} field. Cannot append."
    else
      SearchAndReplaceInFieldOfObject.new(work_value.entries.first, "#{work_value.entries.first} #{csv_value}",
                                          fieldname, work_object)
    end
  end
end

def send_notification_email(recipient); end
