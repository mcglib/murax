namespace :first_deploy do
  desc 'run some rake db task with params'
  task :run_db_task, :param do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
          execute :rake, args[:param]
        end
      end
    end
  end
end
