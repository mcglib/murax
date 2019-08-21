require 'active_record'
require 'optparse'
namespace :murax do
desc 'Creates additional user roles'
task :create_user_roles => :environment do
    options = {
       default_role1: 'repository_managers',
       default_role2: 'casual_workers'
     }
    o = OptionParser.new
    o.banner = "Usage: rake murax:create_user_roles -- --r1 name-of-the-role"
    o.on('-r1 NAME', '--default_role1 NAME') { |default_role1|
      options[:default_role1] = default_role1
    }
    o.on('-r2 NAME', '--default_role2  NAME') { |default_role2|
      options[:default_role2] = default_role2
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
    puts "Finishing the roles creation task. Thank you for using rake automation. You are the best. "
    exit
end
end
