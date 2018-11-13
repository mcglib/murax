# For use in production
set :stage, :production
set :rails_env, 'production'
set :deploy_to, '/storage/www/murax'
set :repository_cache, "git_cache"
set :branch, "master"
#set :ssh_options, keys: ['id_new_rsa'] if File.exist?('id_new_rsa')
#set :ssh_options, { :forward_agent => true }
server 'localhost', user: 'dev.library', roles: [:web, :app, :db]
