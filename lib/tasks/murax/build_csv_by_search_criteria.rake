namespace :murax do
  desc 'Build a csv of (basic) metadata per search criteria. Multiple criteria can be specified as space separated list'
  # call like this: bundle exec rake murax:build_csv_by_search_criteria['French langue Language','department department department']
  task :build_csv_by_search_criteria, [:search_values, :field_list] => :environment do |t,args|
     @search_values = args[:search_values].split(' ')
     @field_list = args[:field_list].split(' ')
     begin
        tod = Time.now.strftime('%Y%m%d-%H%M%S')
        csv_filename = "tmp/metadata_by_search_criteria-#{tod}.csv"
        log_filename = "log/build_csv_by_search_criteria-#{tod}.log"
        csv_file = File.new(csv_filename,'w')
        log_file = File.new(log_filename,'w')

        raise ArgumentError.new("Missing search_values argument") if @search_values.nil?
        raise ArgumentError.new("Missing field_list argument") if @field_list.nil?
        raise ArgumentError.new("Number of search values must match number of fields") if @search_values.count != @field_list.count
        samvera_work_ids = []
        @search_values.zip(@field_list).each do |search_val, field|
           samvera_work_ids << ReportWorkidsService.by_metadata_search(search_val,field)
        end
        works_of_interest = samvera_work_ids.flatten.sort.uniq

        log_file.puts "#{tod} started csv export by search criteria: "+ @search_values.zip(@field_list).join(', ')
        header_line = 'url,title,creator,department,year,bibliographic_citation'
        csv_file.puts header_line

        works_of_interest.each do |wid|
          line = ''
          work = ActiveFedora::Base.find(wid)
          next if work.instance_of? FileSet
          line += '"https://'+ENV['RAILS_HOST']+'/concern/'+work.resource_type.first.pluralize.downcase+'/'+wid+'",'
          line += '"'+work.title.first+'","'
          creators = ''
          work.nested_ordered_creator.each do |creator|
             creators += "#{creator.creator.first},"
          end
          line += creators.delete_suffix(',')+'",'
          datestr = ''
          datestr = work.date.first if !work.date.first.nil?
          line += '"'+datestr+'",'
          bibcit = ''
          bibcit = work.bibliographic_citation.first if !work.bibliographic_citation.first.nil?
          line += '"'+bibcit+'"'
          csv_file.puts line
        end
        log_file.puts "Wrote #{works_of_interest.count} works to csv"
        puts "csv available at #{csv_filename}"
        puts "log available at #{log_filename}"
      rescue ArgumentError => e
        puts "Usage: bundle exec rake murax:build_csv_by_search_criteria['list of search values','list of fields']"
        puts " E.g.: bundle exec rake murax:biuld_csv_by_search_criteria['french language Smith','department department creator']"
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
