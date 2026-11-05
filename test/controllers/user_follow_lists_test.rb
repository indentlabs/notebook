require 'test_helper'

# The followers/following pages page through the follow rows themselves and
# stop at a fixed depth, so a huge follower list can't produce a deep OFFSET.
class UserFollowListsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @followers = 3.times.map do |i|
      User.create!(name: "Follow Tester #{%w[Alpha Bravo Charlie][i]}", email: "follower#{i}@example.com", password: 'password', password_confirmation: 'password')
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

  test "pages past the end clamp to the last page instead of querying deep offsets" do
    get followers_user_path(@user, page: 14644)
    assert_response :success
    @followers.each { |f| assert_includes response.body, ERB::Util.html_escape(f.display_name) }
  end

  test "following page lists followed users" do
    get following_user_path(@followers.first)
    assert_response :success
    assert_includes response.body, ERB::Util.html_escape(@user.display_name)
  end

  test "depth is capped" do
    controller = UsersController.new
    controller.params = ActionController::Parameters.new(page: '9999')
    list = controller.send(:paginated_follow_list, @user.inverse_user_followings, :user_id, 10_000_000, includes: [:avatar_attachment])
    assert_equal UsersController::FOLLOW_LIST_MAX_PAGES, list.total_pages
    assert_equal UsersController::FOLLOW_LIST_MAX_PAGES, list.current_page
  end
end
