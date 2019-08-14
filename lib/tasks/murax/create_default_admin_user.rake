require 'active_record'
require 'optparse'
namespace :murax do
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
end