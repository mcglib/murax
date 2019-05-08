# For use in localhost
set :stage, :production
set :rails_env, 'development'
set :deploy_to, '/storage/www/murax'
set :repository_cache, "git_cache"
server 'localhost', user: 'dev.library', roles: [:web, :app, :db]
