# For use in first ansible deploy
set :stage, :staging
set :rails_env, 'production'
set :deploy_to, '/storage/www/murax'
set :ssh_options, keys: ['id_rsa'] if File.exist?('id_rsa')
server 'qlirap.library.mcgill.ca', user: 'dev.library', roles: [:web, :app, :db]
