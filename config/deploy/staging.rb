# For staging (QA)
set :stage, :production
set :bundle_flags, '--deployment'
set :rails_env, 'production'
set :deploy_to, '/storage/www/murax'
set :repository_cache, "git_cache"
set :branch, "master"
set :ssh_options, { keys: '/root/.ssh/id_rsa', :forward_agent => true}
server 'qlirap.library.mcgill.ca', user: 'dev.library@mcgill.ca', roles: [:web, :app, :db]
