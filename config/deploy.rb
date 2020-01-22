# config valid only for current version of Capistrano
lock "3.9.0"

set :rbenv_ruby, '2.5.3'
set :rbenv_type, :user

set :application, "murax"

set :repo_url, ENV['REPO_URL'] || "ssh://git@scm.library.mcgill.ca:7999/adir/murax.git"
set :repository, ENV['REPO_URL'] || "ssh://git@scm.library.mcgill.ca:7999/adir/murax.git"
# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/storage/www/murax'
set :rails_env, fetch(:stage).to_s
set :ssh_options, keys: ['~/.ssh/id_rsa'] if File.exist?('~/.ssh/id_rsa')
set :ssh_options, { :forward_agent => true }
set :tmp_dir, '/storage/www/tmp'
set :migration_role, :app

set :stages, ["development", "testing", "production"]
set :default_stage, "development"

# Default value for default_env is {}
set :default_env, {
   'http_proxy' => 'http://mirage.ncs.mcgill.ca:3128',
   'https_proxy' => 'http://mirage.ncs.mcgill.ca:3128',
   'HTTPS_PROXY_REQUEST_FULLURI' => 'false',
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
set :pty, true

# Default value for :linked_files is []
#append :linked_files, "config/analytics.yml"
#append :linked_files, "config/browse_everything_providers.yml"
#append :linked_files, "config/database.yml"
#append :linked_files, "config/secrets.yml"
append :linked_files, ".env.production"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
append :linked_dirs, "public/assets"
append :linked_dirs, "tmp/sockets"



# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 3


SSHKit.config.command_map[:rake] = 'bundle exec rake'

# We have to re-define capistrano-sidekiq's tasks to work with
# systemctl in production. Note that you must clear the previously-defined
# tasks before re-defining them.
#Rake::Task["sidekiq:stop"].clear_actions
#Rake::Task["sidekiq:start"].clear_actions
#Rake::Task["sidekiq:restart"].clear_actions
namespace :sidekiq do
  task :stop do
    on roles(:app) do
      execute :sudo, :systemctl, :stop, :sidekiq
      #sudo :systemctl, :stop, :sidekiq
    end
  end
  task :start do
    on roles(:app) do
      execute :sudo, :systemctl, :start, :sidekiq
      #sudo :systemctl, :start, :sidekiq
    end
  end
  task :restart do
    on roles(:app) do
      execute :sudo, :systemctl, :restart, :sidekiq
      #sudo :systemctl, :restart, :sidekiq
    end
  end
end
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

  after :finishing, :restart_apache do
    on roles(:app) do
      sudo :systemctl, :reload, :httpd
    end
  end
  after :finishing, :stop_sidekiq do
    on roles(:app) do
      sudo :systemctl, :stop, :sidekiq
    end
  end
  after :finishing, :start_sidekiq do
    on roles(:app) do
      sudo :systemctl, :start, :sidekiq
    end
  end

  before "deploy:assets:precompile", "deploy:npm_install"
  after  "deploy:npm_install", "deploy:yarn_install"

end
