Unsplash.configure do |config|
  config.application_access_key = ENV['UNSPLASH_ACCESS_KEY']
  config.application_secret = ENV['UNSPLASH_APP_SECRET']
  config.application_redirect_uri = "https://www.notebook.ai/oauth/callback"
  config.utm_source = "notebook.ai"
end
