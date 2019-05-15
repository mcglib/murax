#The task can then be run with bundle exec cap production deploy:initial.
namespace :deploy do
  desc "Performs first deploy to a server by clearing the database before db:migrate"
  task :initial do
    before "deploy:migrate", "deploy:clear_db"
    before "deploy:migrate", "deploy:clear_fedora"
    after  "deploy:migrate", "deploy:create_collections"
    after  "deploy:migrate", "deploy:create_admin_set"
    after  "deploy:migrate", "db:seed"
    invoke "deploy"
  end
  
  task :reset do
    before "deploy:migrate", "deploy:clear_db"
    before "deploy:migrate", "deploy:clear_fedora"
    after  "deploy:migrate", "deploy:create_collections"
    after  "deploy:migrate", "deploy:create_admin_set"
    after  "deploy:migrate", "db:seed"
    invoke "deploy"
  end
  
  task :yarn_install do
    on roles(:app) do
      within release_path do
          with rails_env: "#{fetch(:stage)}" do
              execute("cd #{release_path} && yarn install")
          end
      end
    end
  end

  desc "Run the npm install with proxy enabled"
  task :npm_install do
    on roles(:app) do
      within release_path do
          with rails_env: "#{fetch(:stage)}" do
              execute("cd #{release_path} && export http_proxy='http://mirage.ncs.mcgill.ca:3128' && export https_proxy='http://mirage.ncs.mcgill.ca:3128' && npm install")
          end
      end
    end
  end


  desc "Erase all DB tables"
  task :clear_db do
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
  desc "Create the default collections types"
  task :create_collections do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
         execute :rake, 'hyrax:default_collection_types:create'
        end
      end
    end
  end
  desc "Create the default admin set collection"
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
