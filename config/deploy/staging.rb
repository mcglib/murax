# For staging (QA)
set :stage, :production
set :bundle_flags, '--deployment'
set :rails_env, 'production'
set :deploy_to, '/storage/www/murax'
set :repository_cache, "git_cache"
set :branch, "master"
set :ssh_options, keys: ['id_rsa'] if File.exist?('id_rsa')
server 'qlirap.library.mcgill.ca', user: 'dev.library', roles: [:web, :app, :db]
