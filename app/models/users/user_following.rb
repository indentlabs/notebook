class UserFollowing < ApplicationRecord
  acts_as_paranoid

  belongs_to :user, counter_cache: :following_count
  belongs_to :followed_user, class_name: User.name, counter_cache: :followers_count

  # Backed by a unique index on live follows. Unfollowing only soft-deletes, so it's ignored here and
  # following someone again later still works.
  validates :followed_user_id, uniqueness: { scope: :user_id, conditions: -> { where(deleted_at: nil) } }

  COUNTER_CACHE_COLUMNS = { following_count: :user_id, followers_count: :followed_user_id }.freeze

  # Recounts every user's following_count and followers_count from their live follows, in one statement
  # per counter, writing only the users whose counts are wrong. Returns how many counters it fixed.
  def self.reset_counter_caches
    COUNTER_CACHE_COLUMNS.sum do |counter, column|
      live_follows = "(SELECT COUNT(*) FROM user_followings f WHERE f.#{column} = users.id AND f.deleted_at IS NULL)"
      User.unscoped.where("users.#{counter} <> #{live_follows}").update_all("#{counter} = #{live_follows}")
    end
  end
end
