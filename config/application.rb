require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PlanCharacters
  # Default application environment configurations
  class Application < Rails::Application
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '{*/}')]

    # Set Time.zone default to the specified zone and make Active Record auto-
    # convert to this zone. Run "rake -D time" for a list of tasks for finding
    # time zone names. Default is UTC.
    #
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations
    # from config/locales/*.rb,yml are auto loaded.
    #
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Filter sensitive parameters out of logs
    config.filter_parameters << :password
    config.filter_parameters << :password_confirmation

    # Don't encode ampersands into \u0026 when creating JSON
    config.active_support.escape_html_entities_in_json = false
  end
end
