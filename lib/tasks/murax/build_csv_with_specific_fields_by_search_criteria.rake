namespace :murax do
  desc 'Build a csv of specified metadata per search criteria. Multiple criteria can be specified as space separated list'
  # call like this: bundle exec rake murax:build_csv_with_specific_fields_by_search_criteria['French langue Language','department department department','workid title department']
  task :build_csv_with_specific_fields_by_search_criteria, [:search_values, :search_field_list, :output_field_list] => :environment do |t,args|
     @search_values = args[:search_values].split(' ')
     @search_field_list = args[:search_field_list].split(' ')
     @output_field_list = args[:output_field_list].split(' ')
     begin
        tod = Time.now.strftime('%Y%m%d-%H%M%S')
        csv_filename = "tmp/specified_metadata_by_search_criteria-#{tod}.csv"
        log_filename = "log/build_csv_with_specific_fields_by_search_criteria-#{tod}.log"
        csv_file = File.new(csv_filename,'w')
        log_file = File.new(log_filename,'w')

        raise ArgumentError.new("Missing search_values argument") if @search_values.nil?
        raise ArgumentError.new("Missing search_field_list argument") if @search_field_list.nil?
        raise ArgumentError.new("Missing output_field_list argument") if @output_field_list.nil?
        raise ArgumentError.new("Number of search values must match number of fields") if @search_values.count != @search_field_list.count
        samvera_work_ids = []
        if @search_values.count > 1
          @search_values.zip(@search_field_list).each do |search_val, field|
             samvera_work_ids << ReportWorkidsService.by_metadata_search(search_val,field)
          end
        else
             samvera_work_ids << ReportWorkidsService.by_metadata_search(@search_values.first,@search_field_list.first)
        end
        works_of_interest = samvera_work_ids.flatten.sort.uniq

        log_file.puts "#{tod} started csv export by search criteria: "+ @search_values.zip(@search_field_list).join(', ') + "output fields: "+@output_field_list.join(' ')
        header_line = ''
        @output_field_list.each do |output_field|
            header_line += output_field+","
        end
        csv_file.puts header_line.delete_suffix(",")

        works_of_interest.each do |wid|
          line = ''
          work = ActiveFedora::Base.find(wid)
          next if work.instance_of? FileSet
          @output_field_list.each do |output_field|
             if work.public_send(output_field).nil?
                line += '"",'
             elsif output_field == 'url'
                line += '"https://'+ENV['RAILS_HOST']+'/concern/'+work.resource_type.first.pluralize.downcase+'/'+wid+'",'
             elsif output_field == 'creator'
               creators = ''
               work.nested_ordered_creator.each do |creator|
                  creators += "#{creator.creator.first},"
               end
               line += creators.delete_suffix(',')+'",'
             elsif work.public_send(output_field).respond_to?(:each)
               fieldstr = ''
               work.public_send(output_field).each do |field|
                  fieldstr += "#{field},"
               end 
               line += '"'+fieldstr.delete_suffix(',')+'",'
             else
               line += '"'+work.public_send(output_field)+'",'
             end
          end
          csv_file.puts line.delete_suffix(',')
        end
        log_file.puts "Wrote #{works_of_interest.count} works to csv"
        puts "csv available at #{csv_filename}"
        puts "log available at #{log_filename}"
      rescue ArgumentError => e
        puts "Usage: bundle exec rake murax:build_csv_with_specific_fields_by_search_criteria['list of search values','list of search fields','list of output fields']"
        puts " E.g.: bundle exec rake murax:biuld_csv_with_specific_fields_by_search_criteria['french language Smith','department department creator','url, title, creator']"
        puts "   NB: search values are ORed. I.e. the above example creates a csv containing works with 'french' in department OR 'language' in department, OR 'Smith' in creator." 
        puts e.message
      rescue StandardError => e
        puts e.message
        log_file.puts e.message
        puts "log available at #{log_filename}"
      ensure
        csv_file.close
        log_file.close
      end
  end
end
