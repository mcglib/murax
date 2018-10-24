# deploys to DCE sandbox
set :stage, :sandbox
set :rails_env, 'production'
set :deploy_to, '/storage/www/murax'
server 'dlirap.library.mcgill.ca', user: 'dev.library', roles: [:web, :app, :db]
