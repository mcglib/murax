require 'active_record'
require 'optparse'
namespace :murax do
desc 'Creates additional user roles/groups'
task :create_user_groups => :environment do
    options = {
       default_role1: 'repository_managers',
       default_role2: 'casual_workers'
     }
    o = OptionParser.new
    o.banner = "Usage: rake murax:create_user_groups -- --r1 name-of-the-role/group"
    o.on('-r1 NAME', '--default_role1 NAME') { |default_role1|
      options[:default_role1] = default_role1
    }
    o.on('-r2 NAME', '--default_role2  NAME') { |default_role2|
      options[:default_role2] = default_role2
    } 
    #return `ARGV` with the intended arguments
    args = o.order!(ARGV) {}
    o.parse!(args)
    puts "hello #{options.inspect}"
    start_time = Time.now
    puts "[#{start_time.to_s}] Creating the group :#{options[:default_role1]}"
    new_role = Role.find_or_create_by(name: options[:default_role1])
    new_role.save
    puts "[#{start_time.to_s}] Creating the group :#{options[:default_role2]}"
    new_role2 = Role.find_or_create_by(name: options[:default_role2])
    new_role2.save
    puts "New default role(s)/group(s) with names  '#{options[:default_role1]}' and '#{options[:default_role2]}'  have been created. Thank you for using RAKE automation. You are the best."
    exit
end
end
