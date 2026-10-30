class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.order('happened_at DESC').limit(100)
  end

  def show
    notification = Notification.find_by(id: params[:id])
    return redirect_to root_path unless notification.present?
    return redirect_to root_path unless user_signed_in? && notification.user == current_user

    # Mark this notification as read
    notification.update(viewed_at: DateTime.current) unless notification.viewed_at?

    # Redirect to the notification's link
    redirect_to notification.passthrough_link
  end

  def mark_all_read
    current_user.notifications.where(viewed_at: nil).update_all(viewed_at: DateTime.current)

    redirect_back(fallback_location: root_path, notice: "Your notifications have all been marked read.")
  end
end
