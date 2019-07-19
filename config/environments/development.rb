Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  config.active_record.sqlite3.represent_boolean_as_integer = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Set test-mode Stripe API key
  Stripe.api_key = "sk_test_v37uWbseyPct6PpsfjTa3y1l"
  config.stripe_publishable_key = 'pk_test_eXI4iyJ2gR9UOGJyJERvDlHF'

  # Paperclip config for image uploads
  config.paperclip_defaults = {
    storage: :s3,
    s3_host_name: "s3-#{ENV['S3_REGION']}.amazonaws.com",
    s3_credentials: {
      bucket:            ENV.fetch('S3_BUCKET_NAME',        'notebook-content-uploads'),
      s3_region:         ENV.fetch('S3_REGION',            'us-west-2'),
      access_key_id:     ENV.fetch('AWS_ACCESS_KEY_ID',     ''),
      secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', '')
    }
  }

  Bullet.enable = true
  # Bullet.sentry = true
  Bullet.alert = true
  Bullet.bullet_logger = true
  Bullet.console = true
  # Bullet.growl = true
  # Bullet.xmpp = { :account  => 'bullets_account@jabber.org',
  #                 :password => 'bullets_password_for_jabber',
  #                 :receiver => 'your_account@jabber.org',
  #                 :show_online_status => true }
  Bullet.rails_logger = true
  # Bullet.honeybadger = true
  # Bullet.bugsnag = true
  # Bullet.airbrake = true
  # Bullet.rollbar = true
  Bullet.add_footer = true
end
