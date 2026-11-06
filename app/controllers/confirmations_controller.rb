# Signed-in people usually ask for a new confirmation email from a notice somewhere in the app
# (see shared/_confirm_email_notice), so send them back there instead of to the sign-in page.
class ConfirmationsController < Devise::ConfirmationsController
  protected

  def after_resending_confirmation_instructions_path_for(resource_name)
    return super unless user_signed_in?

    safe_referrer_path || edit_user_registration_path
  end

  private

  def safe_referrer_path
    uri = URI.parse(request.referer.to_s)
    return if uri.host.present? && uri.host != request.host
    return if uri.path.blank? || uri.path == new_user_confirmation_path

    uri.request_uri
  rescue URI::InvalidURIError
    nil
  end
end
