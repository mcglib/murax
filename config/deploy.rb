# config valid only for current version of Capistrano
lock "3.11.2"

set :rbenv_ruby, File.read('.ruby-version').strip
set :rbenv_type, :user

# Set our own instance of sidekiq.

set :application, ENV['APPNAME'] || "murax"

set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb)

set :repo_url, ENV['REPO_URL'] || "git@gitlab.ncs.mcgill.ca:lts/adir/murax.git"
set :repository, ENV['REPO_URL'] || "git@gitlab.ncs.mcgill.ca:lts/adir/murax.git"
# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, ENV['APP_PATH'] || '/storage/www/murax'
set :rails_env, fetch(:stage).to_s

set :ssh_options, keys: ['~/.ssh/id_rsa'] if File.exist?('~/.ssh/id_rsa')
set :ssh_options, { :forward_agent => true }
set :tmp_dir, ENV['TMP_PATH'] || '/storage/www/tmp'
set :migration_role, :app

set :stages, ["development", "testing", "production"]
set :default_stage, "development"

# Default value for default_env is {}
set :default_env, {
}

set :log_level, :debug
#set :bundle_flags, '--deployment'

set :bundle_env_variables, nokogiri_use_system_libraries: 1

# Default branch is :master
set :branch, ENV['REVISION'] || ENV['BRANCH'] || ENV['BRANCH_NAME'] || 'master'

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

# Skip migration if files in db/migrate were not modified
set :conditionally_migrate, true


# Default value for :format is :airbrush.
# set :format, :airbrush

# You can configure the Airbrush format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, false

# Default value for :linked_files is []
#append :linked_files, "config/analytics.yml"
#append :linked_files, "config/browse_everything_providers.yml"
#append :linked_files, "config/database.yml"
#append :linked_files, "config/secrets.yml"
append :linked_files, ".env.production"
#append :linked_files, "escholarship-294403ff986f.p12"
# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
append :linked_dirs, "public/assets"
append :linked_dirs, "public/uploads"
append :linked_dirs, "tmp/sockets"

# role for sitemap_generator
set :sitemap_roles, :web

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 3

set :passenger_roles, :app
set :passenger_restart_runner, :sequence
set :passenger_restart_wait, 5
set :passenger_restart_limit, 2
set :passenger_restart_with_sudo, false
set :passenger_environment_variables, {}
set :passenger_restart_command, 'passenger-config restart-app'
set :passenger_restart_options, -> { "#{deploy_to}/current --ignore-app-not-running" }

set :sidekiq_config, "#{deploy_to}/current/config/sidekiq.yml" # if you have a config/sidekiq.yml, do not forget to set this. 

SSHKit.config.command_map[:rake] = 'bundle exec rake'
SSHKit.config.command_map[:sidekiq] = "bundle exec sidekiq"
SSHKit.config.command_map[:sidekiqctl] = "bundle exec sidekiqctl"

SSHKit.config.command_map[:rake] = 'bundle exec rake'

set :init_system, :systemd
# sidekiq systemd options
# set :service_unit_name, "sidekiq"
# set :sidekiq_service_unit_name, 'sidekiq'
# set :sidekiq_service_unit_user, :system
# set :sidekiq_enable_lingering, false
# set :sidekiq_lingering_user, nil
# set :sidekiq_user, "deploy" #user to run sidekiq as
#




# We have to re-define capistrano-sidekiq's tasks to work with
# systemctl in production. Note that you must clear the previously-defined
# tasks before re-defining them.
#Rake::Task["sidekiq:stop"].clear_actions
#Rake::Task["sidekiq:start"].clear_actions
#Rake::Task["sidekiq:restart"].clear_actions
# Capistrano passenger restart isn't working consistently,
# so restart apache2 after a successful deploy, to ensure
# changes are picked up.
namespace :deploy do
  # @example
  # # bundle exec cap staging deploy:invoke task=salesforce:sync_accounts
  desc "Invoke rake task"
  task :invoke do
    fail 'no task provided' unless ENV['task']
    on roles(:app) do
      within release_path do
          with rails_env: "#{fetch(:stage)}" do
              execute :rake, ENV['task']
          end
      end
    end
  end

  task :refresh_sitemaps do
    on roles(:web) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
          execute("cd #{current_path} &&  RAILS_ENV=production bundle exec rake sitemap:refresh")
        end
      end  
    end
  end

  desc "add symlink to Google's analytics file"
  task :add_google_analytics do
    on roles(:all) do
        within "#{current_path}" do
          with rails_env: "#{fetch(:stage)}" do
            execute "ln -sf #{shared_path }/config/escholarship-294403ff986f.p12 #{release_path}/escholarship-294403ff986f.p12"
          end
        end
    end
  end

 # after :finishing, :restart_apache do
 #   on roles(:app) do
 #     sudo :systemctl, :reload, :httpd
 #   end
 # end
 # after :finishing, :stop_sidekiq do
 #   on roles(:app) do
 #     sudo :systemctl, :stop, 'sidekiq-murax'
 #   end
 # end

 # after :finishing, :start_sidekiq do
 #   on roles(:app) do
 #     sudo :systemctl, :start, 'sidekiq-murax'
 #   end
 # end

  before "deploy:assets:precompile", "deploy:npm_install"
  after "deploy:cleanup", "deploy:refresh_sitemaps"
  after "deploy:finished", "deploy:add_google_analytics" 
  
end
