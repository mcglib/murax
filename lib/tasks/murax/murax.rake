require 'active_record'
require 'optparse'
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

  desc ' Create the default set of user roles'
  task create_default_roles: [:environment] do
    roles = ['admin', 'archivist', 'donor', 'researcher', 'patron', 'admin_policy_object_editor']
    roles.each do |role|
      Role.create(name: "#{role}")
    end
  end


end
