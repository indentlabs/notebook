Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = true

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

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

  # Whitelist HashWithIndifferentAccess/TimeWithZone for changelog serialization
  # config.active_record.yaml_column_permitted_classes = [HashWithIndifferentAccess, ActiveSupport::TimeWithZone, Time]
  config.active_record.use_yaml_unsafe_load = true

  # Set test-mode Stripe API key
  Stripe.api_key = "sk_test_v37uWbseyPct6PpsfjTa3y1l"
  config.stripe_publishable_key = 'pk_test_eXI4iyJ2gR9UOGJyJERvDlHF'

  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  config.active_job.default_url_options    = { host: 'localhost', port: 3000 }

  # Paperclip config for image uploads
  config.paperclip_defaults = {
    storage: :s3,
    s3_credentials: {
      bucket:            ENV.fetch('S3_BUCKET_NAME',        'notebook-content-uploads'),
      s3_region:         ENV.fetch('AWS_REGION',            'us-east-1'),
      access_key_id:     ENV.fetch('AWS_ACCESS_KEY_ID',     ''),
      secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', '')
    }
  }

  Bullet.enable = true
  # Bullet.sentry = true
  Bullet.alert = false
  Bullet.bullet_logger = true
  Bullet.console = true
  Bullet.rails_logger = true
  # Bullet.honeybadger = true
  # Bullet.bugsnag = true
  # Bullet.airbrake = true
  # Bullet.rollbar = true
  Bullet.add_footer = true
end
