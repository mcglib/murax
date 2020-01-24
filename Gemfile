source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

#gem 'rb-readline'
gem 'dotenv-rails'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.6'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use postgresql on the sandbox
gem 'pg', '~> 0.21.0'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.6'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 3.2.0'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

#gem 'curb', '~> 0.9.10'

gem 'whenever', require: false
gem 'xray-rails'

gem 'capistrano-locally', require: false

gem 'ffaker' # Needed so we can load fixtures for demos in production

gem 'tinymce-rails'

gem 'twitter-bootstrap-rails'

gem 'yard'
gem 'webpacker', '~> 3.5'
#gem 'webpacker', '>= 4.0.x'

gem 'rubysl-open3'

#gem 'clamav'
#gem 'exception_handler', '~> 0.8.0.0'

gem "haml-rails", "~> 2.0"
gem "bootstrap-table-rails"


group :development, :test do
  gem 'bixby'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capistrano', '3.9.0'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-sidekiq'
  gem 'capistrano-rbenv', '~> 2.1'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
  gem 'solr_wrapper', '>= 0.3'
  gem 'fcrepo_wrapper'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'awesome_print'
  gem 'capybara', '~> 2.17.0'
  # Lint checker
  gem 'pronto'
end

group :test do
  gem 'rspec-mocks'
  gem 'webmock'
end


group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry'
  gem 'pry-byebug'
end

gem 'sshkit-sudo'
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
#gem 'hyrax', github: 'samvera/hyrax'

gem 'hyrax', '2.5.1'
gem 'hydra-editor'
gem 'hydra-role-management'
gem "rdf-vocab"


gem 'devise'
gem 'devise-i18n'
gem 'devise-guests', '~> 0.6'
#gem 'rsolr', '~> 2.0'
gem 'rsolr'
gem 'jquery-rails'
gem 'sidekiq', '~> 5.2.7'
gem 'sidekiq-limit_fetch'
gem 'sidekiq-status'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'
# gem 'twitter-bootstrap-rails'

gem 'riiif', '~> 2.0'

# OAI provider Gem.
gem 'blacklight_oai_provider', '~> 6.0'
