require 'test_helper'
require 'minitest/mock'

class NanowrimoPromptTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @user.update_columns(time_zone: 'UTC')
    @user.writing_goals.delete_all
    sign_in @user
  end

  # The dashboard's right column, where the invitation sits, only renders
  # alongside a question about one of the writer's pages.
  def get_dashboard_with_a_question
    characters(:one).update_columns(user_id: @user.id)
    @user.user_content_type_activators.find_or_create_by!(content_type: 'Character')
    category = AttributeCategory.create!(user: @user, entity_type: 'character', label: 'Overview', name: 'overview')
    field = AttributeField.create!(user: @user, attribute_category: category, label: 'Backstory',
                                   name: 'backstory', field_type: 'text_area')

    SerendipitousService.stub(:question_for, field) do
      get '/my/dashboard'
    end
  end

  test "the dashboard invites the writer to set a goal for November" do
    travel_to(Time.utc(2026, 10, 29, 12)) do
      get_dashboard_with_a_question
    end

    assert_response :success
    assert_select 'h3', text: /Recently Edited/
    assert_select 'h4', text: /Doing National Novel Writing Month\?/
    assert_select "a[href*='start_date=2026-11-01'][href*='target_word_count=50000']"
    assert_select "a[href*='notice_id=202611']", text: 'Not this year'
  end

  test "the goal form opens filled in for November" do
    travel_to(Time.utc(2026, 10, 29, 12)) do
      get new_writing_goal_path(title: 'National Novel Writing Month 2026', target_word_count: 50_000,
                                start_date: '2026-11-01', days: 30)
    end

    assert_response :success
    assert_select 'input#writing_goal_title[value=?]', 'National Novel Writing Month 2026'
    assert_select 'input#writing_goal_target_word_count[value=?]', '50000'
    assert_select 'input#writing_goal_start_date[value=?]', '2026-11-01'
    assert_select 'input#writing_goal_end_date[value=?]', '2026-12-01'
  end

  test "a malformed start date falls back to today" do
    travel_to(Time.utc(2026, 10, 29, 12)) do
      get new_writing_goal_path(start_date: 'not-a-date', days: 7)
    end

    assert_select 'input#writing_goal_start_date[value=?]', '2026-10-29'
    assert_select 'input#writing_goal_end_date[value=?]', '2026-11-05'
  end

  test "dismissing the invitation removes it from the dashboard" do
    travel_to(Time.utc(2026, 10, 29, 12)) do
      get notice_dismissal_dismiss_path(notice_id: 202611)
      get_dashboard_with_a_question
    end

    assert_response :success
    assert_select 'h3', text: /Recently Edited/
    assert_select 'h4', text: /Doing National Novel Writing Month\?/, count: 0
  end
end
