require 'test_helper'

# Follower lists can be huge (every signup follows user 5), so the pages that show them must never ask the
# database to read a whole list: no DISTINCT, no COUNT, no deep OFFSET. Both of the first two showed up in
# production as multi-second queries on user 5's followers page.
class UserFollowListsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @followers = %w[Alpha Bravo Charlie].map do |name|
      create_user_without_follows(name: "Follow Tester #{name}", email: "follower-#{name.downcase}@example.com")
    end
    UserFollowing.where(followed_user: @user).destroy_all
    @followers.each { |follower| UserFollowing.create!(user: follower, followed_user: @user) }
  end

  test "followers page lists followers, newest first" do
    get followers_user_path(@user)
    assert_response :success

    positions = @followers.reverse.map { |f| response.body.index(ERB::Util.html_escape(f.display_name)) }
    assert positions.all?, 'every follower should be listed'
    assert_equal positions.sort, positions, 'followers should be listed newest first'
  end

  test "following page lists followed users" do
    get following_user_path(@followers.first)
    assert_response :success
    assert_includes response.body, ERB::Util.html_escape(@user.display_name)
  end

  test "unfollowed users drop off the list" do
    UserFollowing.find_by(user: @followers.first, followed_user: @user).destroy

    get followers_user_path(@user)
    assert_response :success
    assert_not_includes response.body, ERB::Util.html_escape(@followers.first.display_name)
  end

  test "pages past the end show the last page instead of querying a deep offset" do
    offsets = list_offsets { get followers_user_path(@user, page: 14644) }

    assert_response :success
    @followers.each { |f| assert_includes response.body, ERB::Util.html_escape(f.display_name) }
    assert_equal [0], offsets
  end

  test "only the newest pages of a huge list can be reached" do
    User.where(id: @user.id).update_all(followers_count: 1_460_000) # counter caches are read-only attributes

    offsets = list_offsets { get followers_user_path(@user, page: 14644) }

    assert_response :success
    max_page = UsersController::FOLLOW_LIST_MAX_PAGES
    assert_select 'em.current', text: max_page.to_s
    assert_select "a[href*='page=#{max_page + 1}']", count: 0
    assert_equal [(max_page - 1) * UsersController::FOLLOW_LIST_PER_PAGE], offsets
  end

  test "follow lists never DISTINCT a user's follows or COUNT their followers" do
    sign_in @followers.first

    [followers_user_path(@user), following_user_path(@followers.first), user_path(@user)].each do |path|
      queries = follow_queries { get path }
      assert_response :success

      assert_empty queries.grep(/DISTINCT/i), "#{path} de-duplicated a whole follow list"
      follower_counts = queries.grep(/COUNT\(/i).grep(/"user_followings"\."followed_user_id" = /)
      assert_empty follower_counts, "#{path} counted a whole follower list instead of using followers_count"
    end
  end

  private

  def follow_queries(&block)
    follow_queries_with_binds(&block).map(&:first)
  end

  # The OFFSET of each paged follow query. SQLite gets it as a bound parameter; Postgres in production
  # (prepared_statements: false) gets it inline.
  def list_offsets(&block)
    follow_queries_with_binds(&block).filter_map do |sql, binds|
      next unless sql.include?('OFFSET')

      sql[/OFFSET (\d+)/, 1]&.to_i || binds.last.to_i
    end
  end

  def follow_queries_with_binds
    queries = []
    callback = lambda do |*, payload|
      next unless payload[:sql].include?('user_followings')

      binds = payload[:type_casted_binds]
      queries << [payload[:sql], binds.respond_to?(:call) ? binds.call : Array(binds)]
    end
    ActiveSupport::Notifications.subscribed(callback, 'sql.active_record') { yield }
    queries
  end
end
