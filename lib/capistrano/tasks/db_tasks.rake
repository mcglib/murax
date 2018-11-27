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

  desc "Erase all DB tables"
  task :clear do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
          conn = ActiveRecord::Base.connection
          tables = conn.tables
          tables.each do |table|
            puts "Deleting #{table}"
            conn.drop_table(table)
          end
        end
      end
    end
  end
end
