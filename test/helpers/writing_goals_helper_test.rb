require 'test_helper'

class WritingGoalsHelperTest < ActionView::TestCase
  include ApplicationHelper
  include WritingGoalsHelper

  setup do
    @user = users(:one)
    @user.update_columns(time_zone: 'UTC')
    @user.writing_goals.delete_all
  end

  def current_user
    @user
  end

  def user_signed_in?
    true
  end

  test "invites writers from October 15 through the end of November" do
    november = Date.new(2026, 11, 1)

    travel_to(Time.utc(2026, 10, 14, 12)) { assert_nil nanowrimo_prompt_start_date }
    travel_to(Time.utc(2026, 10, 15, 12)) { assert_equal november, nanowrimo_prompt_start_date }
    travel_to(Time.utc(2026, 11, 18, 12)) { assert_equal november, nanowrimo_prompt_start_date }
    travel_to(Time.utc(2026, 11, 30, 12)) { assert_equal november, nanowrimo_prompt_start_date }
    travel_to(Time.utc(2026, 12, 1, 12))  { assert_nil nanowrimo_prompt_start_date }
  end

  test "dismissing the invitation hides it for that year only" do
    @user.notice_dismissals.create!(notice_id: nanowrimo_notice_id(2025))
    travel_to(Time.utc(2026, 10, 29, 12)) { assert_equal Date.new(2026, 11, 1), nanowrimo_prompt_start_date }

    @user.notice_dismissals.create!(notice_id: nanowrimo_notice_id(2026))
    travel_to(Time.utc(2026, 10, 29, 12)) { assert_nil nanowrimo_prompt_start_date }
  end

  test "stops inviting once the writer has a goal starting in November" do
    travel_to(Time.utc(2026, 10, 29, 12)) do
      @user.writing_goals.create!(title: 'October sprint', target_word_count: 10_000,
                                  start_date: Date.new(2026, 10, 20), end_date: Date.new(2026, 11, 20))
      assert_not_nil nanowrimo_prompt_start_date, 'a goal that started in October is a different plan'

      goal = @user.writing_goals.create!(title: 'My novel', target_word_count: 50_000,
                                         start_date: Date.new(2026, 11, 1), end_date: Date.new(2026, 12, 1))
      assert_nil nanowrimo_prompt_start_date

      goal.archive!
      assert_not_nil nanowrimo_prompt_start_date, 'archived goals no longer count'
    end
  end

  test "the goal link fills in all of November" do
    path = new_nanowrimo_goal_path(Date.new(2026, 11, 1))
    query = Rack::Utils.parse_query(URI(path).query)

    assert_equal 'National Novel Writing Month 2026', query['title']
    assert_equal '50000', query['target_word_count']
    assert_equal '2026-11-01', query['start_date']
    assert_equal '30', query['days']
  end
end
