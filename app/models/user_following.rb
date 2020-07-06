class UserFollowing < ApplicationRecord
  belongs_to :user
  belongs_to :followed_user, class_name: User.name
end
