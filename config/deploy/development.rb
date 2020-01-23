# For development
set :stage, :production
set :rails_env, 'production'
set :repository_cache, "git_cache"
set :branch, "develop"
set :bundle_without, nil
set :ssh_options, keys: ['id_rsa'] if File.exist?('id_rsa')
server 'dlirap.library.mcgill.ca', user: 'dev.library', roles: [:web, :app, :db]
