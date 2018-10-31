namespace :murax do
  desc "Create the default collections"
  task :create_collections do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
         execute :rake, 'hyrax:default_collection_types:create'
        end
      end
    end
  end
  desc "Create the default admin set"
  task :create_admin_set do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
         execute :rake, 'hyrax:default_admin_set:create'
        end
      end
    end
  end
  desc "Generate a hyrax Work"
  task :generate_work do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
         execute :rake, 'hyrax:work Work'
        end
      end
    end
  end
end
