require 'test_helper'

class WordCountUpdatesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @document = Document.create!(title: 'Test Document', body: 'Test content', user: @user)
  end

  test "should redirect to login when not authenticated" do
    get word_count_updates_path
    assert_redirected_to new_user_session_path
  end

  test "index renders successfully with manual adjustments" do
    sign_in @user
    WordCountUpdate.create!(
      user: @user,
      entity_type: 'ManualAdjustment',
      entity_id: 1,
      word_count: 500,
      for_date: Date.current
    )

    get word_count_updates_path
    assert_response :success
  end

  # Regression test: a legacy/dirty manual-adjustment row with a nil word_count
  # used to crash the page with a 500 because the view evaluated
  # `update.word_count > 0`. The view must tolerate nil and render fine.
  test "index renders when a manual adjustment has a nil word_count" do
    sign_in @user
    record = WordCountUpdate.create!(
      user: @user,
      entity_type: 'ManualAdjustment',
      entity_id: 2,
      word_count: 0,
      for_date: Date.current
    )
    # Bypass the before_validation normalization to simulate a pre-existing
    # nil row in the database.
    record.update_column(:word_count, nil)

    get word_count_updates_path
    assert_response :success
  end

  test "create stores a manual adjustment" do
    sign_in @user
    assert_difference('WordCountUpdate.count', 1) do
      post word_count_updates_path, params: { word_count_update: { for_date: Date.current, word_count: 250 } }
    end
    assert_redirected_to word_count_updates_path
  end

  test "create with blank word count stores zero instead of nil" do
    sign_in @user
    post word_count_updates_path, params: { word_count_update: { for_date: Date.current, word_count: '' } }
    assert_redirected_to word_count_updates_path
    assert_equal 0, @user.word_count_updates.last.word_count
  end
  test "each log row shows what was written that day, not the document's whole size" do
    sign_in @user
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 4_000, for_date: Date.current - 40.days)
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 4_150, starting_word_count: 4_100, for_date: Date.current)

    get word_count_updates_path
    assert_response :success

    assert_includes response.body, '+50 words'
    assert_includes response.body, '4,150 total'
    refute_includes response.body, 'total document size'
  end

  test "a row that changed nothing says so" do
    sign_in @user
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 300, starting_word_count: 300, for_date: Date.current)

    get word_count_updates_path

    assert_includes response.body, 'No new words'
  end

  test "an old row without a starting count is measured from the row before it" do
    sign_in @user
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 900, for_date: Date.current - 3.days)
    WordCountUpdate.create!(user: @user, entity: @document, word_count: 1_000, for_date: Date.current - 1.day)

    get word_count_updates_path

    assert_includes response.body, '+100 words'
    assert_includes response.body, 'first time tracked: whole document counted'
  end

  test "the new adjustment's date defaults to the writer's own today" do
    @user.update!(time_zone: 'Pacific Time (US & Canada)')
    sign_in @user

    travel_to Time.utc(2026, 11, 9, 3, 0) do # Nov 8, 7pm in California
      get word_count_updates_path
      assert_includes response.body, 'value="2026-11-08"'
    end
  end

  test "a manual adjustment needs a date" do
    sign_in @user
    assert_no_difference('WordCountUpdate.count') do
      post word_count_updates_path, params: { word_count_update: { for_date: '', word_count: 250 } }
    end
    assert_redirected_to word_count_updates_path
    assert_match(/date/i, flash[:alert])
  end

  test "several adjustments on the same day each get their own entry" do
    sign_in @user
    assert_difference('WordCountUpdate.count', 3) do
      3.times { post word_count_updates_path, params: { word_count_update: { for_date: Date.current, word_count: 100 } } }
    end
    assert_equal 300, WordCountUpdate.words_written_on_date(@user, Date.current)
  end
end
