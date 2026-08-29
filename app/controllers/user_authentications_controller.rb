##
# Lets a signed-in user disconnect a linked OAuth provider from their account.
# (Connecting happens through the OmniAuth flow in OmniauthCallbacksController.)
class UserAuthenticationsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    authentication = current_user.user_authentications.find_by(id: params[:id])

    if authentication.nil?
      redirect_to user_more_actions_path(current_user), alert: "We couldn't find that linked account."
      return
    end

    # Don't let users strand themselves: their last linked account can only be
    # removed once they've set a password they actually know.
    if current_user.oauth_only? && current_user.user_authentications.count == 1
      redirect_to user_more_actions_path(current_user),
        alert: "You haven't set a password yet, so this linked account is your only way to log in. Set a password first, then disconnect it."
      return
    end

    authentication.destroy
    redirect_to user_more_actions_path(current_user), notice: "Disconnected. You can no longer use that account to log in."
  end
end
