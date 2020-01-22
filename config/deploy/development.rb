# For development
set :stage, :development
set :rails_env, 'development'
set :repository_cache, "git_cache"
set :branch, "develop"
set :ssh_options, keys: ['id_rsa'] if File.exist?('id_rsa')
server 'dlirap.library.mcgill.ca', user: 'dev.library', roles: [:web, :app, :db]
