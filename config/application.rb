require_relative 'boot'

require 'rails/all'

DEVELOPMENT_RAILS_GROUPS = 'web,worker'
if ENV['RAILS_GROUPS'].blank?
  ENV['RAILS_GROUPS'] = DEVELOPMENT_RAILS_GROUPS
  warn "RAILS_GROUPS is unset; defaulting to #{DEVELOPMENT_RAILS_GROUPS}"
elsif ENV['RAILS_GROUPS'] == 'assets'
  puts "RAILS_GROUPS is set to assets (building assets on heroku)"
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
    
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.active_job.queue_adapter = :sidekiq

    config.after_initialize do
      if ENV["MIGRATION_DATABASE_URL"].present?
        puts "Connecting to migration database"
        ActiveRecord::Base.establish_connection(ENV["MIGRATION_DATABASE_URL"])
      end
    end
  end
end
