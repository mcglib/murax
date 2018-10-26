namespace :db do
  desc "reload the database with seed data"
  task :seed do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
         logger.info "Running the seed data first so we have admin account already created"
          execute :rake, 'db:seed'
        end
      end
    end
  end
end
