Rails.application.config.paypal = {
  client_id:     ENV.fetch('PAYPAL_CLIENT_ID', ''),
  client_secret: ENV.fetch('PAYPAL_SECRET',    '')
}
