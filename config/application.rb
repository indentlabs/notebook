require File.expand_path('../boot', __FILE__)
require 'rails/all'

DEVELOPMENT_RAILS_GROUPS = 'web,worker'
if ENV['RAILS_GROUPS'].blank?
  ENV['RAILS_GROUPS'] = DEVELOPMENT_RAILS_GROUPS
  warn "RAILS_GROUPS is unset; defaulting to #{DEVELOPMENT_RAILS_GROUPS}"
elsif ENV['RAILS_GROUPS'] != DEVELOPMENT_RAILS_GROUPS
  warn "RAILS_GROUPS is set to #{ENV['RAILS_GROUPS']} instead of #{DEVELOPMENT_RAILS_GROUPS}"
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Notebook
  class Application < Rails::Application
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '{*/}')]
    config.autoload_paths += Dir[Rails.root.join('app', 'services', '{*/}')]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Use sidekiq to process jobs
    config.active_job.queue_adapter = :sidekiq
  end
end
