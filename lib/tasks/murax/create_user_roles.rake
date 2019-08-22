require 'active_record'
require 'optparse'
namespace :murax do
desc 'Creates additional user roles'
task :create_user_roles => :environment do
    options = {
       role: 'test'
     }
    o = OptionParser.new
    o.banner = "Usage: rake murax:create_user_roles -- --role name-of-the-role"
    o.on('-r NAME', '--role NAME') { | role |
      options[:role] = role
    }
    #return `ARGV` with the intended arguments
    args = o.order!(ARGV) {}
    o.parse!(args)
    #puts "hello #{options.inspect}"
    start_time = Time.now
    options.each do | name, role |
      role_exists = Role.find_by_name("#{role}")
      if role_exists == nil
        puts "[#{start_time.to_s}] Creating the role :#{ role }"
        new_role = Role.create(name: "#{role}")
        new_role.save
        puts "New role: #{new_role['name']} have been created."
      else
        puts "Role: #{role} exists. Moving on ..."
      end
    end
    puts "Finishing the role creation task. Thank you for using rake automation. You are the best. "
    exit
end
end
