# Enable multistage

# Require capistrano locally
require 'capistrano/locally'
# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }

# Load the SCM plugin appropriate to your project:
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Include tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#   https://github.com/capistrano/passenger
#
require "capistrano/rbenv"
require "capistrano/bundler"
require "capistrano/rails/migrations"
require "capistrano/rails/assets"
#require 'capistrano-rails'
require 'sshkit/sudo'
require "whenever/capistrano"
#require 'capistrano/safe_deploy_to'
require 'capistrano/ssh_doctor'
#require "capistrano/passenger"

#require 'capistrano/puma'
#install_plugin Capistrano::Puma

#require 'capistrano/honeybadger'

# Sidekiq
require 'capistrano/sidekiq'
#install_plugin Capistrano::Sidekiq  # Default sidekiq tasks
#require 'capistrano/sidekiq/monit'
#install_plugin Capistrano::Sidekiq::Systemd 
#install_plugin Capistrano::Sidekiq::Monit #, load_hooks: false  # Monit tasks without hooks



# to create sitemap
require 'capistrano/sitemap_generator'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }

