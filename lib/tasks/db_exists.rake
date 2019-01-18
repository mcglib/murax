require 'active_record'
namespace :db do
  desc "Checks to see if the database exists"
  task :exists do
    begin
      db_exists = FALSE
      Rake::Task['environment'].invoke
      if ActiveRecord::Base.connection.table_exists?(:roles) 
      	db_exists = TRUE
      end
    rescue => e
      puts "#{db_exists}"
      puts "Error occured checking if the table exists: #{e}"
      exit 1
    else
      puts "#{db_exists}"
      exit 0
    end
  end
  desc ' Clear out all the DB tables'
  task clean: [:environment] do
  	conn = ActiveRecord::Base.connection
  	tables = conn.tables
  	tables.each do |table|
    	   puts "Deleting #{table}"
    	   conn.drop_table(table, {:force=>:cascade} )
  	end
  end
end
