class AuthcallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.find_by_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', :kind => 'Google'
      sign_in_and_redirect @user, :event => :authentication
    else
      session['devise.google_data'] = request_env['omniauth.auth']
      redirect_to controller: 'registrations', action: 'sign_up'
    end
  end
end
