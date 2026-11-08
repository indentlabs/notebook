require 'test_helper'

class WordCountUpdateTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "wordcount_test@example.com",
      password: "password123",
      time_zone: "Eastern Time (US & Canada)"
    )
    @document = Document.create!(user: @user, title: "Test Doc", body: "Hello world")
  end

  def teardown
    @user.destroy if @user.persisted?
  end

  test "words_written_on_date returns 0 when no records exist" do
    result = WordCountUpdate.words_written_on_date(@user, Date.current)
    assert_equal 0, result
  end

  test "words_written_on_date calculates delta from previous day" do
    # Day 1: Document has 500 words
    WordCountUpdate.create!(
      user: @user,
      entity: @document,
      word_count: 500,
      for_date: Date.current - 1.day
    )

    # Day 2: Document has 700 words (added 200)
    WordCountUpdate.create!(
      user: @user,
      entity: @document,
      word_count: 700,
      for_date: Date.current
    )

    result = WordCountUpdate.words_written_on_date(@user, Date.current)
    assert_equal 200, result, "Should return delta (700 - 500 = 200), not absolute count"
  end

  test "words_written_on_date returns full count when no previous record exists" do
    # First time editing document
    WordCountUpdate.create!(
      user: @user,
      entity: @document,
      word_count: 500,
      for_date: Date.current
    )

    result = WordCountUpdate.words_written_on_date(@user, Date.current)
    assert_equal 500, result, "Should return full count when no baseline exists"
  end

  test "words_written_on_date ignores negative deltas (word deletions)" do
    # Day 1: Document has 1000 words
    WordCountUpdate.create!(
      user: @user,
      entity: @document,
      word_count: 1000,
      for_date: Date.current - 1.day
    )

    # Day 2: Document has 800 words (deleted 200)
    WordCountUpdate.create!(
      user: @user,
      entity: @document,
      word_count: 800,
      for_date: Date.current
    )

    result = WordCountUpdate.words_written_on_date(@user, Date.current)
    assert_equal 0, result, "Should ignore negative deltas (word deletions)"
  end

  test "words_written_in_range calculates total delta across date range" do
    # Before range: Document has 1000 words
    WordCountUpdate.create!(
      user: @user,
      entity: @document,
      word_count: 1000,
      for_date: Date.current - 5.days
    )

    # During range: Document grows to 1500 words
    WordCountUpdate.create!(
      user: @user,
      entity: @document,
      word_count: 1300,
      for_date: Date.current - 2.days
    )

    WordCountUpdate.create!(
      user: @user,
      entity: @document,
      word_count: 1500,
      for_date: Date.current
    )

    range = (Date.current - 3.days)..Date.current
    result = WordCountUpdate.words_written_in_range(@user, range)

    # Should be 1500 (final) - 1000 (baseline before range) = 500
    assert_equal 500, result
  end

  test "words_written_in_range handles multiple documents correctly" do
    doc2 = Document.create!(user: @user, title: "Doc 2", body: "Test")

    # Doc 1: existed before range with 1000 words, grew to 1200 during range
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 1000, for_date: Date.current - 10.days)
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 1200, for_date: Date.current - 1.day)

    # Doc 2: new during range, has 500 words
    WordCountUpdate.create!(user: @user, entity: doc2, word_count: 500, for_date: Date.current)

    range = (Date.current - 5.days)..Date.current
    result = WordCountUpdate.words_written_in_range(@user, range)

    # Doc 1: 1200 - 1000 = 200 words written during range
    # Doc 2: 500 - 0 = 500 words written during range (new document)
    # Total: 700
    assert_equal 700, result
  end

  test "words_written_on_dates returns hash of dates to word counts" do
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 500, for_date: Date.current - 2.days)
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 700, for_date: Date.current - 1.day)
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 800, for_date: Date.current)

    dates = [Date.current - 2.days, Date.current - 1.day, Date.current]
    result = WordCountUpdate.words_written_on_dates(@user, dates)

    assert_equal 500, result[Date.current - 2.days], "Day 1: 500 words (no baseline)"
    assert_equal 200, result[Date.current - 1.day], "Day 2: 700 - 500 = 200 words"
    assert_equal 100, result[Date.current], "Day 3: 800 - 700 = 100 words"
  end

  test "batch_words_written_on_dates returns same results as individual calls" do
    doc2 = Document.create!(user: @user, title: "Doc 2", body: "Test")

    # Create records across multiple days and documents
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 100, for_date: Date.current - 5.days)
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 300, for_date: Date.current - 3.days)
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 500, for_date: Date.current - 1.day)
    WordCountUpdate.create!(user: @user, entity: doc2, word_count: 200, for_date: Date.current - 2.days)
    WordCountUpdate.create!(user: @user, entity: doc2, word_count: 400, for_date: Date.current)

    dates = (0..5).map { |days_ago| Date.current - days_ago.days }

    # Get results from batch method
    batch_result = WordCountUpdate.batch_words_written_on_dates(@user, dates)

    # Compare with individual calls
    dates.each do |date|
      individual_result = WordCountUpdate.words_written_on_date(@user, date)
      assert_equal individual_result, batch_result[date] || 0,
        "Batch and individual results should match for #{date}"
    end
  end

  test "batch_words_written_on_dates handles empty dates" do
    result = WordCountUpdate.batch_words_written_on_dates(@user, [])
    assert_equal({}, result)
  end

  test "batch_words_written_on_dates handles user with no records" do
    dates = [Date.current - 1.day, Date.current]
    result = WordCountUpdate.batch_words_written_on_dates(@user, dates)

    assert_equal 0, result[Date.current - 1.day] || 0
    assert_equal 0, result[Date.current] || 0
  end

  test "dates_with_writing_activity returns set of active dates" do
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 500, for_date: Date.current - 3.days)
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 700, for_date: Date.current - 1.day)

    result = WordCountUpdate.dates_with_writing_activity(@user, Date.current - 5.days, Date.current)

    assert result.is_a?(Set), "Should return a Set"
    assert result.include?(Date.current - 3.days), "Day with 500 words should be active"
    assert result.include?(Date.current - 1.day), "Day with 200 word delta should be active"
    assert_not result.include?(Date.current - 2.days), "Day with no activity should not be included"
    assert_not result.include?(Date.current), "Day with no activity should not be included"
  end

  test "dates_with_writing_activity excludes days with only deletions" do
    # Day 1: Document has 1000 words
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 1000, for_date: Date.current - 2.days)
    # Day 2: Document has 800 words (deleted 200)
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 800, for_date: Date.current - 1.day)
    # Day 3: Document has 900 words (added 100)
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 900, for_date: Date.current)

    result = WordCountUpdate.dates_with_writing_activity(@user, Date.current - 3.days, Date.current)

    assert result.include?(Date.current - 2.days), "Day with initial 1000 words should be active"
    assert_not result.include?(Date.current - 1.day), "Day with only deletions should not be active"
    assert result.include?(Date.current), "Day with 100 word addition should be active"
  end

  test "blank word count is stored as zero" do
    update = WordCountUpdate.create!(
      user: @user,
      entity: @document,
      word_count: nil,
      for_date: Date.current
    )

    assert_equal 0, update.reload.word_count
  end

  test "batch_words_written_on_dates tolerates pre-existing nil word counts" do
    # Simulate a legacy/dirty row that already has a nil word_count in the DB,
    # bypassing the before_validation normalization with update_column.
    record = WordCountUpdate.create!(
      user: @user,
      entity: @document,
      word_count: 0,
      for_date: Date.current
    )
    record.update_column(:word_count, nil)

    assert_nothing_raised do
      result = WordCountUpdate.batch_words_written_on_dates(@user, [Date.current])
      assert_equal 0, result[Date.current]
    end
  end

  # -- Starting counts --

  test "a day with a starting count is measured from it, not from the previous row" do
    # Weeks ago, counted the old way (or with days of untracked writing since)
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 1_000, for_date: Date.current - 30.days)
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 1_250, starting_word_count: 1_200, for_date: Date.current)

    assert_equal 50, WordCountUpdate.words_written_on_date(@user, Date.current)
    assert_equal({ Date.current => 50 }, WordCountUpdate.batch_words_written_on_dates(@user, [Date.current]))
  end

  test "a first-ever row with a starting count doesn't credit the text it started with" do
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 5_030, starting_word_count: 5_000, for_date: Date.current)

    assert_equal 30, WordCountUpdate.words_written_on_date(@user, Date.current)
  end

  test "rows without a starting count still use the previous row" do
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 100, for_date: Date.current - 2.days)
    row = WordCountUpdate.create!(user: @user, entity: @document, word_count: 160, for_date: Date.current)

    assert_equal 100, row.previous_word_count
    assert_equal 100, row.starting_count
    assert_equal 60, row.words_added
    assert_equal 60, row.counted_words
  end

  test "words_added can be negative but counted_words never is" do
    row = WordCountUpdate.create!(user: @user, entity: @document, word_count: 80, starting_word_count: 100, for_date: Date.current)

    assert_equal(-20, row.words_added)
    assert_equal 0, row.counted_words
  end

  test "with_previous_word_count loads each row's previous count in the same query" do
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 100, for_date: Date.current - 3.days)
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 140, for_date: Date.current - 1.day)
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 200, starting_word_count: 150, for_date: Date.current)

    rows = @user.word_count_updates.with_previous_word_count.order(:for_date).to_a
    assert_equal [nil, 100, nil], rows.map(&:previous_word_count)
    assert_equal [100, 40, 50], rows.map(&:words_added)
  end

  test "manual adjustments never subtract an earlier adjustment that happens to share their id" do
    WordCountUpdate.create!(user: @user, entity_type: 'ManualAdjustment', entity_id: 42, word_count: 300, for_date: Date.current - 1.day)
    WordCountUpdate.create!(user: @user, entity_type: 'ManualAdjustment', entity_id: 42, word_count: 100, for_date: Date.current)

    assert_equal 100, WordCountUpdate.words_written_on_date(@user, Date.current)
    assert_equal 400, WordCountUpdate.words_written_in_range(@user, (Date.current - 1.day)..Date.current)
  end

  test "negative manual adjustments subtract" do
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 500, starting_word_count: 0, for_date: Date.current)
    WordCountUpdate.create!(user: @user, entity_type: 'ManualAdjustment', entity_id: 7, word_count: -200, for_date: Date.current)

    assert_equal 300, WordCountUpdate.words_written_on_date(@user, Date.current)
    assert_equal 300, WordCountUpdate.words_written_in_range(@user, Date.current..Date.current)
  end

  test "words_written_in_range starts from the first day's starting count" do
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 900, for_date: Date.current - 20.days)
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 1_100, starting_word_count: 1_000, for_date: Date.current - 2.days)
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 1_300, starting_word_count: 1_100, for_date: Date.current)

    assert_equal 300, WordCountUpdate.words_written_in_range(@user, (Date.current - 7.days)..Date.current)
    assert_equal({ ['Document', @document.id] => 300 },
                 WordCountUpdate.net_words_by_entity(@user, (Date.current - 7.days)..Date.current))
  end

  test "for_date is required" do
    row = WordCountUpdate.new(user: @user, entity_type: 'ManualAdjustment', entity_id: 1, word_count: 10)
    refute row.valid?
    assert_includes row.errors[:for_date], "can't be blank"
  end

  test "date_for uses the writer's time zone and survives an unknown one" do
    late_evening_eastern = Time.utc(2026, 11, 8, 3, 0) # 10pm on Nov 7 in New York

    assert_equal Date.new(2026, 11, 7), WordCountUpdate.date_for(@user, late_evening_eastern)
    assert_equal Date.new(2026, 11, 8), WordCountUpdate.date_for(nil, late_evening_eastern)
    @user.time_zone = 'Not/AZone'
    assert_equal Date.new(2026, 11, 8), WordCountUpdate.date_for(@user, late_evening_eastern)
  end

  test "record! only asks for the starting count when it creates the day's row" do
    asked = 0
    WordCountUpdate.record!(@document, date: Date.current, word_count: 120) { asked += 1; 100 }
    WordCountUpdate.record!(@document, date: Date.current, word_count: 180) { asked += 1; 999 }

    row = @document.word_count_updates.find_by(for_date: Date.current)
    assert_equal 1, asked
    assert_equal 100, row.starting_word_count
    assert_equal 180, row.word_count
  end
end
