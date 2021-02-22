require 'active_record'
require 'optparse'
require 'uri'

namespace :murax do
  desc 'Change user password and email new password to user'
  task :change_user_password, [:user_email, :role] => :environment do |task, args|
    if args.count != 1
      puts "Usage: bundle exec rake murax:change_user_password['users-email-address']"
      puts "       10-character random password will be generated and mailed to the user."
      puts "Expecting one argument. Found #{args.count}"
      exit
    end

    #check :user_email for valid email
    if !args[:user_email].match(URI::MailTo::EMAIL_REGEXP).present?
      puts "Error: Email address is not valid"
      exit
    end

    #check that user already exists
    existing_user = User.find_by_user_key( args[:user_email] )
    if existing_user.nil?
      puts "Error: user #{args[:user_email]} does not exist"
      exit
    end
 
    #Generate a secure 10-character password.
    user_password = Devise.friendly_token.first(10)

    #update user password
    existing_user.password = user_password
    existing_user.save
   
    PasswordMailer.with(user_email: existing_user.email, user_password: user_password).email_user_password.deliver_now
    puts "An email containing the new password has been sent to #{existing_user.email}."

    exit
  end
end
