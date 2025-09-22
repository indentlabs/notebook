class UserFollowing < ApplicationRecord
  belongs_to :user, counter_cache: :following_count
  belongs_to :followed_user, class_name: User.name, counter_cache: :followers_count
end
