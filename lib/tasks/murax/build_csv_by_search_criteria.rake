namespace :murax do
  desc 'Report creators of works in Dept of French lang et litt and variants'
  # call like this: bundle exec rake murax:build_csv_by_search_criteria['French langue Language','department department department']
  task :build_csv_by_search_criteria, [:search_values, :field_list] => :environment do |t,args|
     @search_values = args[:search_values].split(' ')
     @field_list = args[:field_list].split(' ')
     begin
        raise ArgumentError.new("missing search_values argument") if @search_values.nil?
        raise ArgumentError.new("missing field_list argument") if @field_list.nil?
        raise ArgumentError.new("size of search_values must match size of field_list") if @search_values.count != @field_list.count
        samvera_work_ids = []
        @search_values.zip(@field_list).each do |search_val, field|
           samvera_work_ids << ReportWorkidsService.by_metadata_search(search_val,field)
        end
        works_of_interest = samvera_work_ids.flatten.sort.uniq

        puts 'url,title,creator,department,year'
        works_of_interest.each do |wid|
          line = ''
          creators = ''
          work = ActiveFedora::Base.find(wid)
          line += '"https://'+ENV['RAILS_HOST']+'/concern/'+work.resource_type.first.pluralize.downcase+'/'+work.id+'",'
          line += '"'+work.title.first+'","'
          work.nested_ordered_creator.each do |creator|
             creators += "#{creator.creator.first},"
          end
          line += creators.delete_suffix(',')+'","'+work.date.first+'"'
          puts line
        end
      rescue ArgumentError, StandardError => e
        puts e.message
      end
  end
end
