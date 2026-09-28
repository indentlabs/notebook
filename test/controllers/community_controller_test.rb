require 'test_helper'

class CommunityControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  setup do
    Rails.cache.clear
    WordCountUpdate.delete_all
    @user = users(:one)
    [[@user.id, 'Document', 1, Date.current - 3.days, 1_200],
     [@user.id, 'Document', 1, Date.current, 1_450],
     [users(:two).id, 'Character', 2, Date.current - 40.days, 300]].each do |user_id, type, id, date, words|
      WordCountUpdate.insert_all!([{ user_id: user_id, entity_type: type, entity_id: id, for_date: date,
                                     word_count: words, created_at: Time.current, updated_at: Time.current }])
    end
    [Date.current - 40.days, Date.current - 3.days].each { |date| CommunityStatsRollup.new(date).run! }
    CommunityStatsRollup.refresh_recent!

  teardown do
    Rails.cache.clear
  end
  end

  test "is public and shows community totals" do
    get community_path
    assert_response :success
    assert_select 'h1', /None of us writes alone/
    assert_includes response.body, '1,750' # all-time words
    assert_includes response.body, new_user_registration_path
  end

  test "shows signed-in writers their share of today's words" do
    sign_in @user
    get community_path
    assert_response :success
    assert_includes response.body, "added <strong class=\"text-white\">250</strong>"
  end

  test "renders with no writing activity at all" do
    CommunityDailyStat.delete_all
    Rails.cache.clear
    get community_path
    assert_response :success
  end

  test "enqueues a refresh when the stats are stale" do
    CommunityDailyStat.delete_all
    Rails.cache.clear
    assert_enqueued_with(job: CommunityStatsRefreshJob) { get community_path }
  end
end
