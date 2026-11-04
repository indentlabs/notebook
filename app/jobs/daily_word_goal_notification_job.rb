class DailyWordGoalNotificationJob < ApplicationJob
  include ActionView::Helpers::NumberHelper
  queue_as :notifications

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    # Check if goal met (cheap enough to do before taking the lock, and
    # most saves won't cross the goal)
    words_today = user.words_written_today
    goal = user.daily_word_goal
    return unless words_today >= goal

    # This job is enqueued on every word count save, so several can run at
    # once for the same user. Lock the user row so only one of them can pass
    # the "already notified?" check and create the notification.
    user.with_lock do
      return if already_notified_today?(user)

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

  private

  # "Today" must be the user's local day expressed in their own time zone.
  # Calling beginning_of_day on the user's local Date builds midnight in the
  # app's zone (UTC) instead, so for anyone not on UTC the window can miss
  # the current moment entirely (e.g. any evening in the Americas), and the
  # check never finds the notification it just sent.
  def already_notified_today?(user)
    now = Time.current.in_time_zone(user.time_zone)

    user.notifications
      .where(reference_code: 'daily-goal-achieved')
      .where(happened_at: now.beginning_of_day..now.end_of_day)
      .exists?
  end
end
