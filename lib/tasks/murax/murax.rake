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

  desc ' Create the default admin user'
  task create_default_admin_user, [:username, :full_name , :password] => [:environment] do |t, args|
    start_time = Time.now
    puts "[#{start_time.to_s}] Creating the user :#{args[:username]}"
    u = User.find_or_create_by(email: :username || 'admin@example.com')
    u.display_name = :full_name || "Default Admin"
    u.password = :password || 'password'
    u.save
    # Add the user to the roles
    # Add u  to all the admin role
    puts "[#{start_time.to_s}] Created the default user :#{args[:username]}"
    admin_role = Role.find_or_create_by(name: 'admin')
    admin_role.users << u
    admin_role.save
    puts "Added the  user :#{args[:username]} to the role 'admin'"
  end

  desc ' Create the default set of user roles'
  task create_default_roles: [:environment] do
    roles = ['admin', 'archivist', 'donor', 'researcher', 'patron', 'admin_policy_object_editor']
    roles.each do |role|
      Role.create(name: "#{role}")
    end
  end


end
