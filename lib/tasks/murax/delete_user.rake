require 'active_record'
require 'optparse'
require 'uri'

namespace :murax do
  desc 'Deletes a user'
  task :delete_user, [:user_email] => :environment do |task, args|
    if args.count < 1
      puts "Usage: bundle exec rake murax:delete_user['users-email-address']"
      puts "      Provide an email address of the user you want to delete from the system"
      puts "Expecting one argument found #{args.count}"
      exit
    end

    #check :user_email for valid email
    if !args[:user_email].match(URI::MailTo::EMAIL_REGEXP).present?
      puts "Error: The argument must be a valid email address"
      exit
    end

    #check if the user exists and delete it. 
    existing_user = User.find_by_user_key( args[:user_email] )
    if existing_user !=  nil
	    existing_user.delete
	    puts "User '#{existing_user}' has been deleted. Thank you for your patience. "
    else
	    puts "Error: user #{args[:user_email]} does not exist in the system."
	    puts "Did you enter the correct email address? "
    end
    exit
  end
end
