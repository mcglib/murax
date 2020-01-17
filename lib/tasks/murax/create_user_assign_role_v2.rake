require 'active_record'
require 'optparse'
require 'uri'

namespace :murax do
  desc 'Create a user and assign to a role'
  task :create_user_assign_role_v2, [:user_email, :role] => :environment do |task, args|
    if args.count < 2
      puts "Usage: bundle exec rake murax:create_user_assign_role['users-email-address','a-role-which-already-exists']"
      puts "       10-character random password will be generated and mailed to the user."
      puts "Expecting two arguments found #{args.count}"
      exit
    end

    #check :user_email for valid email
    if !args[:user_email].match(URI::MailTo::EMAIL_REGEXP).present?
      puts "Error: The first argument must be a valid email address"
      exit
    end

    #check if user already exists
    existing_user = User.find_by_user_key( args[:user_email] )
    if existing_user !=  nil
      puts "Error: user #{args[:user_email]} already exists"
      exit
    end

    #generate 10 character password
    generated_password = Devise.friendly_token.first(10)
 
    #check if role exists
    existing_role = Role.find_by(name: args[:role])
    if existing_role == nil
      puts "error: Role '#{args[:role]}' does not exist."
      exit
    end

    #create user
    start_time = Time.now
    puts "[#{start_time.to_s}] Creating the user: #{args[:user_email]}"
    u = User.new(email: args[:user_email])
    u.display_name = args[:user_email]
    u.password = generated_password
    u.save

    # add user to role
    existing_role.users << u
    existing_role.save

    puts "Added the user: #{args[:user_email]} to the role '#{args[:role]}'"

    puts "Sending an email to #{u.email}."

    UserCreationMailer.with(user_email: u.email, user_name: u.display_name, user_password: generated_password, assigned_role: existing_role).user_password_email.deliver_now
    puts "An email has been sent to #{u.email} with the password and assigned role info."

    exit
  end
end
