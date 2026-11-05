require 'test_helper'

# Following is idempotent: a double-clicked follow button, or a second tab, makes one follow and one notification.
class FollowingSomeoneTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @follower = create_user_without_follows(name: 'Following Test Follower', email: 'following-follower@example.com')
    @followed = create_user_without_follows(name: 'Following Test Followed', email: 'following-followed@example.com')
    sign_in @follower
  end

  test "following someone twice makes one follow and sends one notification" do
    assert_difference [-> { UserFollowing.count }, -> { @followed.notifications.count }], 1 do
      2.times do
        post user_followings_path, params: { user_following: { followed_user_id: @followed.id } }
        assert_redirected_to @followed
      end
    end
    assert_equal 1, @followed.reload.followers_count
  end

  test "losing a race with another follow request still takes you to the person, without a second notification" do
    # The other request's follow lands after this one checked for an existing follow, but before it inserted its own
    original_callbacks = UserFollowing.send(:get_callbacks, :create) # protected
    UserFollowing.set_callback(:create, :before) do
      UserFollowing.insert_all([{ user_id: user_id, followed_user_id: followed_user_id, created_at: Time.current, updated_at: Time.current }])
    end

    assert_no_difference -> { @followed.notifications.count } do
      post user_followings_path, params: { user_following: { followed_user_id: @followed.id } }
    end
    assert_redirected_to @followed
  ensure
    UserFollowing.send(:set_callbacks, :create, original_callbacks) if original_callbacks
  end
end
