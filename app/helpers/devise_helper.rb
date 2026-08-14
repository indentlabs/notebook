module DeviseHelper
  def devise_error_messages!
    resource.errors.full_messages.map { |msg| content_tag(:li, msg + '.') }.join.html_safe
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  # OAuth providers that have credentials configured, so login/signup pages
  # only show buttons that will actually work.
  def configured_oauth_providers
    {
      google_oauth2: ENV['GOOGLE_OAUTH_CLIENT_ID'],
      discord:       ENV['DISCORD_CLIENT_ID']
    }.select { |_provider, client_id| client_id.present? }.keys
  end
end