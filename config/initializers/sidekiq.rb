# Sidekiq configuration for version 7+
Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }
end

# Sidekiq Web UI setup
require 'sidekiq/web'

# Configure Web UI
Sidekiq::Web.app_url = '/'  # Set the app URL for navigation 