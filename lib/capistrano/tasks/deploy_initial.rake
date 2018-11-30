#The task can then be run with bundle exec cap production deploy:initial.
namespace :deploy do
  desc "Performs first deploy to a server by clearing the database before db:migrate"
  task :initial do
    before "deploy:migrate", "deploy:clear"
    before "deploy:migrate", "deploy:clear_fedora"
    after "deploy:migrate", "deploy:create_collections"
    after "deploy:migrate", "deploy:create_admin_set"
    after "deploy:migrate", "db:seed"
    invoke "deploy"
  end
  
  desc "Erase all DB tables"
  task :clear do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
         execute :rake, 'murax:db_clean'
        end
      end
    end
  end

  desc "Erase / Clear out fedora data"
  task :clear_fedora do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
         execute :rake, 'murax:fedora_clean'
        end
      end
    end
  end
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
