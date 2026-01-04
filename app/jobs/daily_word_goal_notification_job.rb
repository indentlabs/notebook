class DailyWordGoalNotificationJob < ApplicationJob
  include ActionView::Helpers::NumberHelper
  queue_as :notifications

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    today = user.current_date_in_time_zone
    today_start = today.beginning_of_day
    today_end = today.end_of_day

    # Already notified today? Check notifications table
    already_notified = user.notifications.where(
      reference_code: 'daily-goal-achieved'
    ).where(happened_at: today_start..today_end).exists?
    return if already_notified

    # Check if goal met
    words_today = user.words_written_today
    goal = user.daily_word_goal
    return unless words_today >= goal

    # Send congratulatory notification
    user.notifications.create!(
      message_html: "Congratulations! You hit your daily word goal of #{number_with_delimiter(goal)} words!",
      icon: 'emoji_events',
      icon_color: 'yellow',
      passthrough_link: '/writing-goals',
      reference_code: 'daily-goal-achieved',
      happened_at: Time.current
    )
  end
end
