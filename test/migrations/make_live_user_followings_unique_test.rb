require 'test_helper'
require Rails.root.join('db/migrate/20261105130000_make_live_user_followings_unique')

# Production has duplicate follows from before follows were unique. This runs the migration that removes
# them against real duplicates (the test runs in a transaction, so the dropped index comes back afterwards).
class MakeLiveUserFollowingsUniqueTest < ActiveSupport::TestCase
  setup do
    @a, @b, @c = %w[a b c].map do |n|
      create_user_without_follows(email: "dedupe-#{n}@example.com")
    end

    ActiveRecord::Migration.suppress_messages { migration.migrate(:down) }
    @kept       = UserFollowing.create!(user: @a, followed_user: @b)
    @duplicates = 2.times.map { UserFollowing.new(user: @a, followed_user: @b).tap { |f| f.save!(validate: false) } }
    @unfollowed = UserFollowing.create!(user: @c, followed_user: @b).tap(&:destroy)
    @refollow   = UserFollowing.create!(user: @c, followed_user: @b)
    @other      = UserFollowing.create!(user: @b, followed_user: @a)
  end

  test "keeps the oldest of each duplicate follow, soft-deletes the rest and fixes the counters" do
    assert_equal 4, @b.reload.followers_count, 'each duplicate was counted'

    ActiveRecord::Migration.suppress_messages { migration.migrate(:up) }

    assert_equal [@kept, @refollow].map(&:id).sort, UserFollowing.where(followed_user: @b).pluck(:id).sort
    @duplicates.each { |dup| assert UserFollowing.only_deleted.exists?(dup.id), 'duplicates should be soft-deleted, not removed' }
    assert UserFollowing.exists?(@other.id)

    assert_equal 2, @b.reload.followers_count
    assert_equal 1, @a.reload.following_count
    assert_equal 1, @a.followers_count
  end

  test "leaves the database refusing new duplicates" do
    ActiveRecord::Migration.suppress_messages { migration.migrate(:up) }

    assert_raises(ActiveRecord::RecordNotUnique) do
      UserFollowing.new(user: @a, followed_user: @b).save!(validate: false)
    end
  end

  test "changes nothing when there are no duplicates" do
    UserFollowing.where(id: @duplicates.map(&:id)).delete_all

    assert_no_difference -> { UserFollowing.only_deleted.count } do
      ActiveRecord::Migration.suppress_messages { migration.migrate(:up) }
    end
    assert UserFollowing.exists?(@kept.id)
  end

  private

  def migration
    @migration ||= MakeLiveUserFollowingsUnique.new
  end
end
