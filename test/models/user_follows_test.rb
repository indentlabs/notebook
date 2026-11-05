require 'test_helper'

# Follows are unique per pair of users (among live, non-deleted follows), which is what lets the follower
# associations skip DISTINCT and lets the counter caches stand in for counting.
class UserFollowsTest < ActiveSupport::TestCase
  setup do
    @follower = create_user_without_follows(name: 'Follows Test Follower', email: 'follows-follower@example.com')
    @followed = create_user_without_follows(name: 'Follows Test Followed', email: 'follows-followed@example.com')
  end

  test "you can't follow the same person twice" do
    UserFollowing.create!(user: @follower, followed_user: @followed)
    duplicate = UserFollowing.new(user: @follower, followed_user: @followed)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:followed_user_id], 'has already been taken'
  end

  test "the database refuses a duplicate follow even when validations are skipped" do
    UserFollowing.create!(user: @follower, followed_user: @followed)

    assert_raises(ActiveRecord::RecordNotUnique) do
      UserFollowing.new(user: @follower, followed_user: @followed).save!(validate: false)
    end
  end

  test "you can follow someone again after unfollowing them" do
    UserFollowing.create!(user: @follower, followed_user: @followed).destroy

    assert UserFollowing.create(user: @follower, followed_user: @followed).persisted?
    assert_equal 1, @followed.reload.followers_count
  end

  test "following and unfollowing keep both counters right" do
    follow = UserFollowing.create!(user: @follower, followed_user: @followed)
    assert_equal [1, 1], [@follower.reload.following_count, @followed.reload.followers_count]

    follow.destroy
    assert_equal [0, 0], [@follower.reload.following_count, @followed.reload.followers_count]
  end

  test "reset_counter_caches recounts live follows and fixes only wrong counters" do
    UserFollowing.create!(user: @follower, followed_user: @followed)
    UserFollowing.create!(user: @followed, followed_user: @follower).destroy
    UserFollowing.reset_counter_caches # whatever the fixtures left behind

    User.where(id: @follower.id).update_all(following_count: 7, followers_count: 3) # counter caches are read-only attributes

    assert_equal 2, UserFollowing.reset_counter_caches
    assert_equal [1, 0], [@follower.reload.following_count, @follower.followers_count]
    assert_equal 0, UserFollowing.reset_counter_caches
  end

  test "follower lists are newest first and leave out unfollows" do
    others = %w[one two three].map do |n|
      create_user_without_follows(email: "follows-other-#{n}@example.com")
    end
    others.each { |other| UserFollowing.create!(user: other, followed_user: @followed) }
    UserFollowing.find_by(user: others.first, followed_user: @followed).destroy

    assert_equal others.drop(1).reverse, @followed.followers_newest_first.to_a
    others.drop(1).each { |other| UserFollowing.create!(user: @followed, followed_user: other) }
    assert_equal others.drop(1).reverse, @followed.followed_users_newest_first.to_a
  end
end
