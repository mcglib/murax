#The task can then be run with bundle exec cap production deploy:initial.
namespace :deploy do
  desc "Performs first deploy to a server by clearing the database before db:migrate"
  task :initial do
    before "deploy:assets:precompile", "deploy:clear"
    before "deploy:assets:precompile", "murax:clear_fedora"
    #after "deploy:migrate", "db:seed"
    #after "deploy:migrate", "murax:create_collections"
    #after "deploy:migrate", "murax:create_admin_set"
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

end
