class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])

    Mixpanel::Tracker.new(Rails.application.config.mixpanel_token).track(@user.id, 'viewed profile', {
      'sharing any content': @user.public_content_count != 0
    })
  end
end
