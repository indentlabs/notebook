##
# Handles OAuth callbacks from external login providers (Google, Discord).
# One shared handler covers every provider: sign in if the identity is already
# linked, link it to the signed-in (or email-matched) account, or create a
# brand-new account.
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  PROVIDER_NAMES = {
    'google_oauth2' => 'Google',
    'discord'       => 'Discord'
  }.freeze

  def handle_oauth_callback
    auth = request.env['omniauth.auth']

    # A signed-in user clicking a provider button is linking that provider to
    # their account, not logging in.
    return link_provider_to_current_user(auth) if user_signed_in?

    user = User.from_omniauth(auth)

    if user.persisted?
      if user.previously_new_record?
        UserOnboardingService.link_pending_contributor_invites(user)
        UserOnboardingService.record_referral(user, session.delete(:referral))
      end

      set_flash_message(:notice, :success, kind: provider_name) if is_navigational_format?
      sign_in_and_redirect user, event: :authentication
    else
      error_details = " (#{user.errors.full_messages.to_sentence.downcase})" if user.errors.any?
      flash[:alert] = "We couldn't create an account from your #{provider_name} login#{error_details}. Please sign up below instead."
      redirect_to new_user_registration_url
    end
  end

  alias google_oauth2 handle_oauth_callback
  alias discord handle_oauth_callback

  private

  def link_provider_to_current_user(auth)
    existing = UserAuthentication.find_by(provider: auth.provider, uid: auth.uid)

    if existing.nil?
      current_user.user_authentications.create(provider: auth.provider, uid: auth.uid)
      flash[:notice] = "Your #{provider_name} account is now linked. You can use it to log in from now on."
    elsif existing.user_id == current_user.id
      flash[:notice] = "Your #{provider_name} account is already linked."
    else
      flash[:alert] = "That #{provider_name} account is already linked to a different Notebook.ai account."
    end

    redirect_to user_more_actions_path(current_user)
  end

  def provider_name
    PROVIDER_NAMES.fetch(request.env.dig('omniauth.auth', 'provider').to_s, 'external')
  end
end
