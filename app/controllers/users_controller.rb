class UsersController < ApplicationController
  def index
    redirect_to new_session_path(User)
  end

  def show
    @user = User.find(params[:id])

    Mixpanel::Tracker.new(Rails.application.config.mixpanel_token).track(@user.id, 'viewed profile', {
      'sharing any content': @user.public_content_count != 0
    }) if Rails.env.production?
  end
end
