namespace :murax do
  desc 'Report work ids for works with abstracts which contain html entities'
  task :get_work_ids_for_abstracts_containing_entities, [:pattern] => :environment do |t,arg|
    search_pattern = arg[:pattern]
    puts ReportWorkidsService.by_metadata_search(search_pattern,'abstract')
  end
end
