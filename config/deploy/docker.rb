# For use in docker
set :rbenv_path, "/usr/local/rbenv"
set :stage, :development
set :rails_env, 'development'
set :deploy_to, '/storage/www/murax'
set :repository_cache, "git_cache"
set :branch, "develop"
#set :ssh_options, keys: ['id_new_rsa'] if File.exist?('id_new_rsa')
#set :ssh_options, { :forward_agent => true }
server 'localhost', user: 'root', roles: [:web, :app, :db]
