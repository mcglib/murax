source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'dotenv-rails'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.6'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use postgresql on the sandbox
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'whenever', require: false
gem 'xray-rails'

gem 'factory_bot_rails' # Needed so we can load fixtures for demos in production
gem 'ffaker' # Needed so we can load fixtures for demos in production

group :development, :test do
  gem 'bixby'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capistrano', '3.9.0'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-sidekiq'
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
  gem 'solr_wrapper', '>= 0.3'
  gem 'fcrepo_wrapper'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
end

group :test do
  gem 'capybara', '~> 2.13'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
end


group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'better_errors'
  gem 'binding_of_caller'
  #gem 'pry'
  #gem 'pry-byebug'
end

gem 'sshkit-sudo'
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
#gem 'hyrax', github: 'samvera/hyrax'
gem 'hyrax', '2.3.3'
gem 'devise'
gem 'devise-i18n'
gem 'devise-guests', '~> 0.6'
#gem 'rsolr', '~> 2.0'
gem 'rsolr', '>= 1.0'
gem 'jquery-rails'
gem 'hydra-role-management'
gem 'clamav'
gem 'sidekiq'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'
# gem 'twitter-bootstrap-rails'



gem 'riiif', '~> 1.1'

