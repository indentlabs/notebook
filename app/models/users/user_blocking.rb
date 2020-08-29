class UserBlocking < ApplicationRecord
  belongs_to :user
  belongs_to :blocked_user, class_name: User.name

  after_create do
    # If a user blocks someone, we should automatically unfollow both pairings
    UserFollowing.find_by(user_id: self.user_id, followed_user_id: self.blocked_user_id).try(:destroy)
    UserFollowing.find_by(user_id: self.blocked_user_id, followed_user_id: self.user_id).try(:destroy)
  end
end
