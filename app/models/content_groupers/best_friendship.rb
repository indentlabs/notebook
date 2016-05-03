class BestFriendship < ActiveRecord::Base
  belongs_to :user

  belongs_to :character
  belongs_to :best_friend, :class_name => "Character"
end
