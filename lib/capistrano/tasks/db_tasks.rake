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
end
