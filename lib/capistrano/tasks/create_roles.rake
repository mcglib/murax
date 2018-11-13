namespace :murax do
    desc "Create Roles for the application"
    task :create_roles do
        on roles(:app) do
          within "#{current_path}" do
            with rails_env: "#{fetch(:stage)}" do
              roles = ['admin', 'archivist', 'donor', 'researcher', 'patron', 'admin_policy_object_editor']
              roles.each do |role|
                  Role.create(name: "#{role}")
              end
            end
          end
        end
    end
end

