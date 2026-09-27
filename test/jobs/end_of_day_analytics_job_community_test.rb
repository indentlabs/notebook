require 'test_helper'

class EndOfDayAnalyticsJobCommunityTest < ActiveJob::TestCase
  test "finalizes yesterday's community word counts and records completed goals" do
    Rails.cache.clear
    WordCountUpdate.delete_all
    yesterday = Date.current - 1.day
    WordCountUpdate.insert_all!([{ user_id: users(:one).id, entity_type: 'Document', entity_id: 1, word_count: 900,
                                   for_date: yesterday, created_at: Time.current, updated_at: Time.current }])

    EndOfDayAnalyticsJob.perform_now

    assert_equal 900, CommunityDailyStat.where(date: yesterday, metric: 'words').sum(:value)
    refute_nil EndOfDayAnalyticsReport.find_by(day: yesterday).writing_goals_completed
  ensure
    Rails.cache.clear
  end
end
