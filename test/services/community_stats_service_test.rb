require 'test_helper'

class CommunityStatsServiceTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
    WordCountUpdate.delete_all
    @today = Date.current
    @alice = users(:one)
    @bob   = users(:two)
  end

  teardown do
    Rails.cache.clear
  end

  def log(user, type, id, date, words, updated_at: Time.current)
    WordCountUpdate.insert_all!([{
      user_id: user.id, entity_type: type, entity_id: id, word_count: words,
      for_date: date, created_at: updated_at, updated_at: updated_at
    }])
  end

  def roll_up(*dates)
    dates.each { |date| CommunityStatsRollup.new(date).run! }
    CommunityStatsRollup.record_point_in_time_metrics!(@today)
  end

  def stats
    CommunityStatsService.new(today: @today)
  end

  test "counts positive growth per entity since its previous record, across users" do
    log(@alice, 'Document', 1, @today - 10.days, 1_000) # baseline, long before
    log(@alice, 'Document', 1, @today - 2.days, 1_500)  # +500
    log(@bob,   'Character', 7, @today - 2.days, 200)   # +200 (first record)
    log(@bob,   'Location', 3, @today - 2.days, 50)
    roll_up(@today - 10.days, @today - 2.days)

    assert_equal 750, stats.daily_words[@today - 2.days]
    assert_equal 1_000, stats.daily_words[@today - 10.days]
    assert_equal 2, stats.daily_writers[@today - 2.days]
    assert_equal 1_750, stats.all_time_words
    assert_equal 2, stats.all_time_writers
  end

  test "deletions never subtract from community totals" do
    log(@alice, 'Document', 1, @today - 3.days, 2_000)
    log(@alice, 'Document', 1, @today - 2.days, 500) # shrank
    log(@bob,   'Document', 2, @today - 2.days, 100)
    roll_up(@today - 2.days)

    assert_equal 100, stats.daily_words[@today - 2.days]
    assert_equal 1, stats.daily_writers[@today - 2.days]
  end

  test "refresh_recent! rolls up today using history from before today" do
    log(@alice, 'Document', 1, @today - 40.days, 10_000)
    log(@alice, 'Document', 1, @today, 10_300)
    log(@bob,   'ManualAdjustment', 99, @today, 250)
    CommunityStatsRollup.refresh_recent!(today: @today)

    assert_equal 550, stats.words_today
    assert_equal 2, stats.writers_today
    assert_equal 2, stats.writers_this_hour
    refute stats.stale?
  end

  test "re-rolling a day replaces its numbers instead of adding to them" do
    log(@alice, 'Document', 1, @today, 300)
    roll_up(@today)
    WordCountUpdate.where(entity_id: 1).update_all(word_count: 800)
    roll_up(@today)
    Rails.cache.clear

    assert_equal 800, stats.words_today
    assert_equal 1, stats.writers_in_month(@today.beginning_of_month)
  end

  test "writers are only counted as active this hour when their counts changed recently" do
    log(@alice, 'Document', 1, @today, 300, updated_at: 3.hours.ago)
    roll_up(@today)
    assert_equal 0, stats.writers_this_hour
  end

  test "groups words into categories by month" do
    month = @today.beginning_of_month
    log(@alice, 'Document',  1, month, 400)
    log(@alice, 'Character', 2, month, 100)
    log(@bob,   'Creature',  3, month, 60)
    log(@bob,   'TimelineEvent', 4, month, 40)
    roll_up(month)

    by_category = stats.words_by_category_in_month(month)
    assert_equal 400, by_category['Documents']
    assert_equal 100, by_category['Characters']
    assert_equal 60,  by_category['Other worldbuilding']
    assert_equal 40,  by_category['Timelines']
    assert_equal 2, stats.writers_in_month(month)

    series = stats.monthly_category_series(months: 2)
    assert_equal 'Documents', series.first[:name]
    assert_equal 400, series.first[:data].last.last
  end

  test "reads creation, sign-up, goal, and forum stats from end-of-day reports" do
    EndOfDayAnalyticsReport.delete_all
    month = @today.beginning_of_month
    EndOfDayAnalyticsReport.create!(day: month, characters_created: 3, documents_created: 5, user_signups: 7,
                                    writing_goals_completed: 1, thredded_replies_created: 4)
    EndOfDayAnalyticsReport.create!(day: month + 1.day, characters_created: 2, user_signups: 1)
    EndOfDayAnalyticsReport.create!(day: month - 1.day, characters_created: 100) # last month

    assert_equal({ 'Document' => 5, 'Character' => 5 }, stats.pages_created_in_month(month))
    assert_equal 8, stats.new_writers_in_month(month)
    assert_equal 1, stats.goals_completed_in_month(month)
    assert_equal 4, stats.forum_posts_in_month(month)
  end

  test "every page type shown has an end-of-day report column" do
    CommunityStatsService.page_classes.each do |klass|
      assert EndOfDayAnalyticsReport.column_names.include?("#{klass.name.downcase.pluralize}_created"), klass.name
    end
  end

  test "records, rhythms, and heatmap handle an empty community" do
    s = stats
    assert s.stale?
    assert_equal 0, s.all_time_words
    assert_nil s.record_day
    assert_nil s.busiest_month
    assert_nil s.favorite_weekday
    assert_equal 0, s.heatmap_level(0)
    assert(s.heatmap_weeks.all? { |week| week.length == 7 })
    assert_equal 30, s.daily_series(days: 30).length
  end

  test "record day and heatmap levels reflect the busiest days" do
    log(@alice, 'Document', 1, @today - 5.days, 100)
    log(@alice, 'Document', 2, @today - 4.days, 5_000)
    log(@alice, 'Document', 3, @today - 3.days, 300)
    roll_up(@today - 5.days, @today - 4.days, @today - 3.days)

    assert_equal({ date: @today - 4.days, words: 5_000 }, stats.record_day)
    assert_equal 4, stats.heatmap_level(5_000)
    assert_equal 1, stats.heatmap_level(100)
  end
end
