require 'active_record'
require 'optparse'
require 'uri'

namespace :murax do
  desc 'Create a user and assign to a role'
  task :create_user_assign_role, [:user_email, :password, :role] => :environment do |task, args|
    if args.count < 3
      puts "Usage: bundle exec rake murax:create_user_assign_role['users-email-address','password','a-role-which-already-exists']"
      puts "       If password is less than 8 characters, a 8-character random password will be generated instead."
      puts "Expecting three arguments found #{args.count}"
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

    #check :password
    if args[:password].length < 8
      #TODO: generate a random password and email it to user (after account is created) if supplied password is too short, 
      #      otherwise use the supplied password
      puts "Error: password should be at least 8 characters long"
      exit
    end

    #check if role exists
    existing_role = Role.find_by(name: args[:role])
    if existing_role == nil
      puts "Error: Role '#{args[:role]}' does not exist."
      exit
    end

    #create user
    start_time = Time.now
    puts "[#{start_time.to_s}] Creating the user: #{args[:user_email]}"
    u = User.new(email: args[:user_email])
    u.display_name = args[:user_email]
    u.password = args[:password]
    u.save

    # add user to role
    existing_role.users << u
    existing_role.save

    puts "Added the user: #{args[:user_email]} to the role '#{args[:role]}'"

    exit
  end
end
