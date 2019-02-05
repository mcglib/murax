require 'active_record'
namespace :murax do
  desc ' Clear out all the DB tables'
  task db_clean: [:environment] do
  	conn = ActiveRecord::Base.connection
  	tables = conn.tables
  	tables.each do |table|
    	   puts "Deleting #{table}"
    	   conn.drop_table(table, {:force=>:cascade} )
  	end
  end
end
