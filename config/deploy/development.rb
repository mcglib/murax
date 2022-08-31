# For development
set :stage, :production
set :rails_env, 'production'
set :deploy_to, '/storage/www/murax'
set :repository_cache, "git_cache"
set :bundle_flags, '--deployment'
set :branch, "develop"
set :ssh_options, { keys: '/root/.ssh/id_rsa', :forward_agent => true}
server 'dlirap.library.mcgill.ca', user: 'dev.library@mcgill.ca', roles: [:web, :app, :db]
