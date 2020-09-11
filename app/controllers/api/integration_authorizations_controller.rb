module Api
  class IntegrationAuthorizationsController < ApplicationController
    protect_from_forgery

    def create
      authorization = IntegrationAuthorization.create(integration_authorization_params.merge({
        user_id:      current_user.id,
        referral_url: request.referrer,
        ip_address:   request.remote_ip,
        origin:       request.headers['HTTP_ORIGIN'],
        content_type: request.headers['CONTENT_TYPE'],
        user_agent:   request.headers['HTTP_USER_AGENT'],
        user_token:   SecureRandom.hex(24)
      }))
      return redirect_to(authorization.application_integration.authorization_callback_url + "?token=#{authorization.user_token}")
    end

    private

    def integration_authorization_params
      params.require(:integration_authorization).permit(:application_integration_id)
    end
  end
end