# For use in first ansible deploy
set :stage, :localhost
set :rails_env, 'production'
set :deploy_to, '/storage/www/murax'
server '127.0.0.1', user: 'dev.library', roles: [:web, :app, :db]
