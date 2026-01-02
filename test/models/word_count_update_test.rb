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
end
