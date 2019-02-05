require 'active_record'
namespace :murax do
  desc ' Clear out all the DB tables'
  task import: [:environment] do
  	conn = ActiveRecord::Base.connection
  	tables = conn.tables
  	tables.each do |table|
    	   puts "Deleting #{table}"
    	   conn.drop_table(table, {:force=>:cascade} )
  	end
  end
  desc "Adds sample data for oai tests"
  task :test_data_import => :environment do
	  sample_data = YAML.load(File.read(File.expand_path('../oai_sample_documents.yml', __FILE__)))
	  sample_data.each do |data|
	    doc = data[1]
	    work = Work.new
	    work.creator = [doc['creator']]
	    work.depositor = doc['depositor']
	    work.label = doc['label']
	    work.title = [doc['title']]
	    puts "Importing document #{doc['title']}"
	    work.date_created = doc['date_created']
	    work.date_modified = doc['date_modified']
	    work.contributor = [doc['contributor']]
	    work.description = doc['description']
	    work.related_url = [doc['related_url']]
	    work.resource_type = [doc['resource_type']]
	    work.language = [doc['language']]
	    work.language_label = [doc['language_label']]
	    work.rights_statement = doc['rights_statement']
	    work.visibility = doc['visibility']
	    work.save
	    sleep 1
	  end
   end
end

