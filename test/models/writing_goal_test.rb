require 'test_helper'

class WritingGoalTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "writinggoal_test@example.com",
      password: "password123",
      time_zone: "Eastern Time (US & Canada)"
    )
    @document = Document.create!(user: @user, title: "Test Doc", body: "Hello world")

    # Create a writing goal that started 5 days ago and ends in 5 days
    @goal = WritingGoal.create!(
      user: @user,
      title: "Test Goal",
      target_word_count: 10000,
      start_date: Date.current - 5.days,
      end_date: Date.current + 5.days
    )
  end

  def teardown
    @user.destroy if @user.persisted?
  end

  test "words_written_during_goal uses delta calculation, not absolute sum" do
    # Before goal: Document had 1000 words
    WordCountUpdate.create!(
      user: @user,
      entity: @document,
      word_count: 1000,
      for_date: Date.current - 10.days  # Before goal started
    )

    # During goal: Document grew to 1500 words
    WordCountUpdate.create!(
      user: @user,
      entity: @document,
      word_count: 1500,
      for_date: Date.current - 3.days
    )

    result = @goal.words_written_during_goal

    # Should be 1500 - 1000 = 500 words written during goal
    # NOT 1500 (absolute count)
    assert_equal 500, result, "Should calculate delta from pre-goal baseline"
  end

  test "words_written_during_goal counts new documents correctly" do
    # Document created during goal
    WordCountUpdate.create!(
      user: @user,
      entity: @document,
      word_count: 750,
      for_date: Date.current - 2.days
    )

    result = @goal.words_written_during_goal

    # No baseline exists before goal, so full count = 750
    assert_equal 750, result
  end

  test "words_written_during_goal handles multiple documents" do
    doc2 = Document.create!(user: @user, title: "Doc 2", body: "Test")

    # Doc 1: existed before goal with 1000 words, grew to 1200
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 1000, for_date: Date.current - 10.days)
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 1200, for_date: Date.current - 2.days)

    # Doc 2: new during goal, has 500 words
    WordCountUpdate.create!(user: @user, entity: doc2, word_count: 500, for_date: Date.current - 1.day)

    result = @goal.words_written_during_goal

    # Doc 1: 1200 - 1000 = 200
    # Doc 2: 500 - 0 = 500
    # Total: 700
    assert_equal 700, result
  end

  test "daily_word_counts returns proper deltas for each day" do
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 500, for_date: Date.current - 4.days)
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 700, for_date: Date.current - 3.days)
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 800, for_date: Date.current - 2.days)

    result = @goal.daily_word_counts

    assert_equal 500, result[Date.current - 4.days], "Day 1: 500 words (no baseline)"
    assert_equal 200, result[Date.current - 3.days], "Day 2: 700 - 500 = 200 words"
    assert_equal 100, result[Date.current - 2.days], "Day 3: 800 - 700 = 100 words"
  end

  test "progress_percentage uses delta-based word count" do
    # Goal is 10000 words
    # Before goal: Document had 5000 words
    WordCountUpdate.create!(
      user: @user,
      entity: @document,
      word_count: 5000,
      for_date: Date.current - 10.days
    )

    # During goal: Document grew to 6000 words
    WordCountUpdate.create!(
      user: @user,
      entity: @document,
      word_count: 6000,
      for_date: Date.current - 2.days
    )

    # Should be 1000 / 10000 = 10%
    assert_equal 10.0, @goal.progress_percentage
  end

  test "words_remaining uses delta-based word count" do
    # Goal is 10000 words
    WordCountUpdate.create!(
      user: @user,
      entity: @document,
      word_count: 3000,
      for_date: Date.current - 2.days
    )

    # Wrote 3000 words, 7000 remaining
    assert_equal 7000, @goal.words_remaining
  end
end
