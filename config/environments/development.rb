Rails.application.configure do
  # Verifies that versions and hashed value of the package contents in the project's package.json
  config.webpacker.check_yarn_integrity = false

  #config.active_job.queue_adapter = :inline
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.seconds.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end


  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  # Execption handler
  #config.exception_handler = {
  #    dev:        nil, # allows you to turn ExceptionHandler "on" in development
  #    db:         nil, # allocates a "table name" into which exceptions are saved (defaults to nil)
  #    email:      nil, # sends exception emails to a listed email (string // "you@email.com")
  #    exceptions: {
  #      :all => {
  #        layout: "exception", # define layout
  #      },
  #      500 => {
  #        layout: "exception", # define layout
  #      }
  #    }
  #}
  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :smtp
  # SMTP settings for mailgun
  ActionMailer::Base.smtp_settings = {
    :port           => ENV['MAIL_PORT'],
    :address        => ENV['MAIL_HOST'],
    #:user_name      => ENV['MAIL_USERNAME'],
    #:password       => ENV['MAIL_PASSWORD'],
    :authentication => :plain,
  }
  config.action_mailer.default_url_options = { :host => ENV['SITE_URL'] }
end
