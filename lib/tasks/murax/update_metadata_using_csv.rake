require 'active_record'
require 'csv'

namespace :murax do
  desc 'Update metadata for specified workids using data provided in a CSV file.'
  task :update_metadata_using_csv, [:csv_file, :user_email] => :environment do |task, args|
    if args.count < 2
      puts
      puts 'Usage: bundle exec rake murax:update_metadata_using_csv["<csv-filename>,<notification-email-recipient>"]'
      puts '       The task expects to find the csv file in the tmp directory'
      exit
    end
    @user_email = args.user_email
    @csv_file = args.csv_file
    @nested_ordered_elements = {'nested_ordered_creator'=>'creator'}
    start_time = Time.now
    datetime_today = Time.now.strftime('%Y%m%d%H%M%S')
    @logger = ActiveSupport::Logger.new("log/update_metadata_using_csv-#{datetime_today}.log")
    @logger.info "Task started at #{start_time}"

    if File.file?("tmp/"+@csv_file)
       process_csv(@csv_file)
    else
       puts "Can't find #{@csv_file} in tmp directory."
       puts "bye"
       exit
    end
    send_notification_email(@user_email) if @user_email.present?
  end
end

def process_csv(filename)
  action = []
  table = CSV.parse(File.read("tmp/#{filename}"), headers: true)
  action = table[0]
  table.each do |row|
    next if row['id'] == action['id']
    workid = row['id']
    work = ActiveFedora::Base.find(workid)
    work.attributes.each do |field, value|
      if table.headers.include?(field)
        next if action[field] == 'Info'
        if action[field] == 'Overwrite'
          overwrite_field(field,row[field],workid)
        else
          if action[field] == 'Appended'
             append_to_field(field,row[field],workid)
          else
             puts "Unrecognized action #{action[field]}"
          end
        end
      end
    end
  end
end

def overwrite_field(fieldname,csv_value,work_id)
  @logger.info "Overwrite #{fieldname} for work id #{work_id} with #{csv_value}"
  if csv_value.include? '|'
      @logger.info "skip to multivalue function for #{fieldname}"
      overwrite_field_with_multivalue(fieldname,csv_value,work_id)
  else
     work_object = ActiveFedora::Base.find(work_id)
     if @nested_ordered_elements.has_key?(fieldname)
        # update of nested_ordered_elements is not working 
        @logger.info "update a nested ordered element #{fieldname} with #{csv_value}"
        work_object[fieldname].clear
        #we have only one nested_ordered_element to create
        new_field = { index: '0', @nested_ordered_elements[fieldname].to_sym => csv_value }
        begin
          work_field = work_object[fieldname]
          work_field.build(new_field)
          work_object.save!
        rescue StandardError => e
          puts "error was #{e.message}"
        end
     else
       if work_object[fieldname].instance_of? String
         @logger.info "update a string"
         work_object[fieldname] = csv_value
         work_object.save!
       else
         @logger.info "update something which is not a string"
         begin
            # this isn't working either
            new_field = Array.new
            new_field << csv_value
            work_object[fieldname] = new_field
            work_object.save!
         rescue StandardError => e
           puts e.message
         end
       end
     end
     @logger.info "work_object[#{fieldname}] is now #{work_object[fieldname]}"
  end
end

def overwrite_field_with_multivalue(fieldname,csv_value,work_id)
   @logger.info "overwrite #{fieldname} with multivalue in #{work_id} with #{csv_value}"
   csv_values = csv_value.split "|"
   work_object = ActiveFedora::Base.find(work_id)
   work_object.attributes[fieldname] = nil
   if @nested_ordered_elements.has_key?(fieldname)
      # update of nested_ordered_elements is not working
      csv_values.each_with_index do |v,i| 
         work_object.attributes[fieldname] << { index: i.to_s, @nested_ordered_elements[fieldname].to_sym => v }
      end
   else
      # this is not working either
      work_object[fieldname].clear()
      csv_values.each do |v|
         work_object[fieldname] << v
         work_object.save!
      end
   end
   work_object.save!
end


def append_to_field(fieldname, csv_value, work_id)
  #currently trying to append to multivalued fields will throw an error.  Should this be revised?
  @logger.info "append to field #{fieldname} for work id #{work_id} with #{csv_value}"
  if csv_value.include? '|'
     @logger.info "Cannot append multi-valued field (CSV contains: #{csv_value} for work id #{work_id})"
  else
     work_object = ActiveFedora::Base.find(work_id)
     work_value = work_object.attributes[fieldname]
     if @nested_ordered_elements.has_key?(fieldname)
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
     else
       # This is working! for both String and Array objects
       if work_value.instance_of? String
         SearchAndReplaceInFieldOfObject.new(work_value,"#{work_value} #{csv_value}",fieldname,work_object)
       else
         if work_value.count > 1
           @logger.info "work #{work_object['id']} has more than one #{fieldname} field. Cannot append."
         else
           SearchAndReplaceInFieldOfObject.new(work_value.entries.first,"#{work_value.entries.first} #{csv_value}",fieldname,work_object)
         end
       end
     end
  end
end

def send_notification_email(recipient)
end
