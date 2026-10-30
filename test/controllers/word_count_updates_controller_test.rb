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
end
