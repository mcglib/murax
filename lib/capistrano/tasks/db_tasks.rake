require 'active_record'
namespace :db do
  desc "reload the database with seed data"
  task :seed do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
         execute :rake, 'db:seed'
        end
      end
    end
  end
  desc "Runs rails db:setup"
  task :create_db do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rails, "db:setup"
        end
      end
    end
  end

end
