class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications.order('happened_at DESC').limit(100)
  end

  def show
    notification = Notification.find_by(id: params[:id])
    return unless notification.present?
    return unless user_signed_in? && notification.user == current_user

    # Mark this notification as read
    notification.update(viewed_at: DateTime.current) unless notification.viewed_at?

    # Redirect to the notification's link
    redirect_to notification.passthrough_link
  end
end
