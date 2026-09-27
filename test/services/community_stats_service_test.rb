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

  def stats
    CommunityStatsService.new(today: @today)
  end

  test "counts positive growth per entity since its previous record, across users" do
    log(@alice, 'Document', 1, @today - 10.days, 1_000) # before the tracked day, baseline
    log(@alice, 'Document', 1, @today - 2.days, 1_500)  # +500
    log(@bob,   'Character', 7, @today - 2.days, 200)   # +200 (first record)
    log(@bob,   'Location', 3, @today - 2.days, 50)

    assert_equal 750, stats.daily_words[@today - 2.days]
    assert_equal 1_000, stats.daily_words[@today - 10.days]
    assert_equal 2, stats.daily_writers[@today - 2.days]
  end

  test "deletions never subtract from community totals" do
    log(@alice, 'Document', 1, @today - 3.days, 2_000)
    log(@alice, 'Document', 1, @today - 2.days, 500) # shrank
    log(@bob,   'Document', 2, @today - 2.days, 100)

    assert_equal 100, stats.daily_words[@today - 2.days]
    assert_equal 1, stats.daily_writers[@today - 2.days]
  end

  test "today's live numbers use history from before today" do
    log(@alice, 'Document', 1, @today - 40.days, 10_000)
    log(@alice, 'Document', 1, @today, 10_300)
    log(@bob,   'ManualAdjustment', 99, @today, 250)

    assert_equal 550, stats.words_today
    assert_equal 2, stats.writers_today
    assert_equal 2, stats.writers_this_hour
    assert_equal 10_550, stats.all_time_words
  end

  test "writers are only counted as active this hour when their counts changed recently" do
    log(@alice, 'Document', 1, @today, 300, updated_at: 3.hours.ago)
    assert_equal 0, stats.writers_this_hour
  end

  test "groups words into categories by month" do
    month = @today.beginning_of_month
    log(@alice, 'Document',  1, month, 400)
    log(@alice, 'Character', 2, month, 100)
    log(@bob,   'Creature',  3, month, 60)
    log(@bob,   'TimelineEvent', 4, month, 40)

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

  test "records, rhythms, and heatmap handle an empty community" do
    s = stats
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

    assert_equal({ date: @today - 4.days, words: 5_000 }, stats.record_day)
    assert_equal 4, stats.heatmap_level(5_000)
    assert_equal 1, stats.heatmap_level(100)
  end
end
