require 'test_helper'

class DailyWordGoalNotificationJobTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @user.notifications.where(reference_code: 'daily-goal-achieved').delete_all
  end

  teardown do
    travel_back
  end

  def write_words(count)
    WordCountUpdate.create!(
      user: @user,
      entity_type: 'ManualAdjustment',
      entity_id: 0,
      word_count: count,
      for_date: @user.current_date_in_time_zone
    )
  end

  def goal_notifications
    @user.notifications.where(reference_code: 'daily-goal-achieved')
  end

  # Evening in a time zone behind UTC: the user's local date is still
  # "yesterday" in UTC terms, which used to put Time.current outside the
  # window the job checked, so every save sent another notification.
  [
    ['Pacific Time (US & Canada)', Time.utc(2026, 11, 4, 3, 0)],  # 7pm PST, Nov 3
    ['Tokyo',                      Time.utc(2026, 11, 4, 20, 0)], # 5am JST, Nov 5
    ['UTC',                        Time.utc(2026, 11, 4, 12, 0)]
  ].each do |zone, now|
    test "only notifies once per day for a user in #{zone}" do
      @user.update_columns(time_zone: zone)
      travel_to now

      write_words(1_500)
      3.times { DailyWordGoalNotificationJob.perform_now(@user.id) }

      assert_equal 1, goal_notifications.count
    end
  end

  test "notifies again on the user's next local day" do
    @user.update_columns(time_zone: 'Pacific Time (US & Canada)')
    travel_to Time.utc(2026, 11, 4, 3, 0) # Nov 3, 7pm PST
    write_words(1_500)
    DailyWordGoalNotificationJob.perform_now(@user.id)

    travel_to Time.utc(2026, 11, 5, 3, 0) # Nov 4, 7pm PST
    write_words(3_000) # counts are cumulative: 1,500 new words today
    DailyWordGoalNotificationJob.perform_now(@user.id)

    assert_equal 2, goal_notifications.count
  end

  test "does not notify below the goal" do
    write_words(10)
    DailyWordGoalNotificationJob.perform_now(@user.id)

    assert_equal 0, goal_notifications.count
  end
end
