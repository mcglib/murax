require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HyraxDemo
  class Application < Rails::Application
    # Added the Canadian timezone for object imports
    config.time_zone = 'Eastern Time (US & Canada)'
    config.active_record.default_timezone = :local # Or :utc

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.active_job.queue_adapter = :sidekiq

    #config.exception_handler = { dev: nil }

    # We handle our own exceptions for 404 and 422 and 500
    config.exceptions_app = self.routes

    config.i18n.available_locales = [:en, :fr]
  end
end
