# For use in first ansible deploy
set :stage, :development
set :rails_env, 'development'
set :deploy_to, '/storage/www/murax'
set :ssh_options, keys: ['id_rsa'] if File.exist?('id_rsa')
server '127.0.0.1', user: 'vagrant', roles: [:web, :app, :db]
