class UserFollowingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_following, only: [:destroy]

  # POST /user_followings
  def create
    user = User.find_by(id: user_following_params.fetch(:followed_user_id))
    return unless user.present?
    return if user_signed_in? && current_user.blocked_by?(user)

    # Following someone you already follow (a double-click, or a second tab) just takes you to them
    @user_following = current_user.user_followings.find_or_initialize_by(followed_user_id: user.id)
    return redirect_to(user, notice: following_notice(user)) if @user_following.persisted?

    if @user_following.save

      # Create a notification letting the user know!
      @user_following.followed_user.notifications.create(
        message_html:     "<div><span class='#{User.text_color}'>#{@user_following.user.display_name}</span> is now following your public updates.</div>",
        icon:             User.icon,
        icon_color:       User.color,
        happened_at:      DateTime.current,
        passthrough_link: Rails.application.routes.url_helpers.user_path(@user_following.user),
        reference_code:   'followed-by-user'
      )

      redirect_to user, notice: following_notice(user)
    else
      redirect_back fallback_location: root_path, alert: 'There was a problem following this user. Please try again.'
    end
  rescue ActiveRecord::RecordNotUnique
    # Two follow requests at once: the other one got there first and made the follow (and the notification)
    redirect_to user, notice: following_notice(user)
  end

  # DELETE /user_followings/1
  def destroy
    user = @user_following.followed_user

    @user_following.destroy
    redirect_to user, notice: "You're no longer following this user."
  end

  private

  def following_notice(user)
    "You're now following #{user.name.presence || 'this user'}"
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_user_following
    @user_following = current_user.user_followings.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def user_following_params
    params.require(:user_following).permit(:followed_user_id)
  end
end
