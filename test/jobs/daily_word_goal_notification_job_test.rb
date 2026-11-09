require 'test_helper'

class DailyWordGoalNotificationJobTest < ActiveJob::TestCase
  setup do
    @user = User.create!(email: 'goal_notice@example.com', password: 'password123', time_zone: 'Pacific Time (US & Canada)')
    @document = Document.create!(user: @user, title: 'Novel', body: '<p>Start.</p>')
  end

  test "a writer west of UTC is congratulated once per evening, not after every save" do
    goal = @user.daily_word_goal
    # 5pm in California, which is already tomorrow in UTC
    travel_to Time.utc(2026, 11, 9, 1, 0) do
      today = @user.current_date_in_time_zone
      @document.word_count_updates.create!(user: @user, for_date: today, starting_word_count: 0, word_count: goal + 10)

      3.times { DailyWordGoalNotificationJob.perform_now(@user.id) }

      assert_equal 1, @user.notifications.where(reference_code: 'daily-goal-achieved').count
    end
  end
end
