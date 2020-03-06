require 'active_record'

namespace :murax do
  desc 'Add a role to collection'
  task :add_role_to_collection, [:collection_id, :role, :access_level] => :environment do |task, args|
    include Hyrax
    if args.count < 3
      puts "Usage: bundle exec rake murax:add_role_to_collection['an existing collection id','an existing role', 'access_level']"
      puts "       This task will assign the role to the collection. Hyrax collections have 3 sharing access levels, 'manage', 'deposit' and 'view'."
      puts "Expecting three arguments found #{args.count}"
      exit
    end

    #check if role exists
    existing_role = Role.find_by(name: args[:role])
    existing_role = existing_role.name
    if existing_role == nil
      puts "error: Role '#{args[:role]}' does not exist."
      exit
    end

    #check if the collection exists
    existing_collection = Collection.find(args[:collection_id])
    if existing_collection == nil
      puts "error: Collection '#{args[:collection]}' does not exist."
      exit
    end

    #check the access levels for collections. Hyrax has 3 access levels.
    existing_access_levels = ["manage", "deposit", "view"]
    access_level = args[:access_level].downcase
    if !existing_access_levels.include? access_level
      puts "error: Access level '#{arge[:access_level]}' does not match, please enter the correct one."
      exit
    end

    #Get the Hyrax::PermissionTemplateAccess for a given access level.
    if access_level == "manage"
      access_template = Hyrax::PermissionTemplateAccess::MANAGE
    elsif access_level == "deposit"
      access_template = Hyrax::PermissionTemplateAccess::DEPOSIT
    elsif access_level == "view"
      access_template = Hyrax::PermissionTemplateAccess::VIEW
    else 
      puts "Access level is not in the system"
      exit
    end
     
    #Hyrax collection service adds the owner as manager by default in Hyrax::PermissionTemplate for each Collection.
    admin_email = ENV['ADMIN_EMAIL'] 
    dev_user = User.find_by_user_key(admin_email)
    
    #Each collection is assigned one PermissionTemplate which then is used for PermissionTemplateAccess.
    if Hyrax::PermissionTemplate.find_by(source_id: args[:collection_id]) == nil
      Hyrax::Collections::PermissionsCreateService.create_default(collection: existing_collection,  creating_user: dev_user)
    end
    
    #Create grants for collection, this is a [array<hash>] param. 
    col_grants = [ { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: existing_role, access: access_template } ]

    #Service that grants the access levels and adds the roles. 
    Hyrax::Collections::PermissionsCreateService.add_access(collection_id: args[:collection_id], grants: col_grants) 

    puts "Added the role: '#{args[:role]}' with access level: '#{access_level}' to the collection: '#{existing_collection}' with the id of: '#{args[:collection_id]}'."
    puts "Thank you for using this task, we appreciate your business. Have a good day!"

    exit
  end
end
