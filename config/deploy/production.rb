# For use in production
set :stage, :production
set :rails_env, 'production'
set :deploy_to, '/storage/www/murax'
set :bundle_flags, '--deployment'
set :repository_cache, "git_cache"
set :branch, "master"
set :ssh_options, keys: ['id_rsa'] if File.exist?('id_rsa')
server 'plirap.library.mcgill.ca', user: 'dev.library', roles: [:web, :app, :db]
