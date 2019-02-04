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
  

  #bundle exec rake murax:create_digitool_collections -- -f config/digitool_collections.json --owner dev.library.mcgill.ca
  desc 'Create the default collections via a json file'
  task :create_digitool_collections => :environment do
    require "#{Rails.root}/app/services/find_or_create_collection" # <-- HERE!
    options = {
          file: 'config/digitool_collections.json',
          owner: 'dev.library@mcgill.ca'
    }
    o = OptionParser.new
    o.banner = "Usage: rake create_digitool_collections [options]"
    o.on('-f FILENAME', '--filename FILENAME') { |file|
      options[:file] = file
    }
    o.on('-o EMAIL', '--owner EMAIL') { |owner|
      options[:owner] = owner
    }
    #return `ARGV` with the intended arguments
    args = o.order!(ARGV) {}
    o.parse!(args)
    puts "hello #{options.inspect}"
    start_time = Time.now
    
    collection_metadata = JSON.parse(File.read(File.join(Rails.root, options[:file])))
    collection_metadata.each do |c|
      slug = c['slug']
      if c['slug'].present?
        collection = FindOrCreateCollection.create(slug, options[:owner])
        puts "Added the collection  :#{c['title']} to the collection type: #{c['collection_type']}"
      end
    end
    puts "Added the  user :#{options[:full_name]} to the role 'admin'"
    exit

  end

  desc 'Create the default admin user'
  task :create_default_admin_user => :environment do
    options = {
          full_name: 'Admin user',
          password: 'password',
          email: 'admin@dlirap.library.mcgill.ca'
    }
    o = OptionParser.new

    o.banner = "Usage: rake create_default_admin_user [options]"
    o.on('-n NAME', '--full_name NAME') { |full_name|
      options[:full_name] = full_name
    }
    o.on('-e EMAIL', '--email EMAIL') { |email|
      options[:email] = email
    }
    o.on('-p PASSWORD', '--password PASSWORD') { |password|
      options[:password] = password
    }

    #return `ARGV` with the intended arguments
    args = o.order!(ARGV) {}
    o.parse!(args)
    puts "hello #{options.inspect}"
    start_time = Time.now
    puts "[#{start_time.to_s}] Creating the user :#{options[:full_name]}"
    u = User.find_or_create_by(email: options[:email] || 'admin@example.com')
    u.display_name = options[:full_name] || "Default Admin"
    u.password = options[:password] || 'password'
    u.save
    # Add the user to the roles
    # Add u  to all the admin role
    puts "[#{start_time.to_s}] Created the default user  in the role :#{options[:full_name]}"
    admin_role = Role.find_or_create_by(name: 'admin')
    admin_role.users << u
    admin_role.save
    puts "Added the  user :#{options[:full_name]} to the role 'admin'"
    exit
  end

  desc ' Create the default set of user roles'
  task create_default_roles: [:environment] do
    roles = ['admin', 'archivist', 'donor', 'researcher', 'patron', 'admin_policy_object_editor']
    roles.each do |role|
      Role.create(name: "#{role}")
    end
  end


end
