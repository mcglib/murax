# For development
set :stage, :development
set :rails_env, 'production'
set :deploy_to, '/storage/www/murax'
set :ssh_options, keys: ['id_rsa'] if File.exist?('id_rsa')
server 'dlirap.library.mcgill.ca', user: 'dev.library', roles: [:web, :app, :db]
