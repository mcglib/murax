namespace :murax do
    desc "Create Roles for the application"
    task create_roles: :environment do
        roles = ['admin', 'archivist', 'donor', 'researcher', 'patron', 'admin_policy_object_editor']
        roles.each do |role|
            Role.create(name: "#{role}")
        end
    end
end

