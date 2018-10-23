# For use in first ansible deploy
set :stage, :localhost
set :rails_env, 'productions'
set :deploy_to, '/storage/www/murax/current'
server '127.0.0.1', user: 'dev.library', roles: [:web, :app, :db]
