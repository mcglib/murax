# For use in production
set :stage, :localhost
set :rails_env, 'production'
set :deploy_to, '/storage/www/murax'
set :ssh_options, keys: ['id_rsa'] if File.exist?('id_rsa')
server '127.0.0.1', user: 'dev.library', roles: [:web, :app, :db]
