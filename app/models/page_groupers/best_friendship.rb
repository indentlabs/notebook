class BestFriendship < ApplicationRecord
  include HasContentLinking

  belongs_to :user

  belongs_to :character
  belongs_to :best_friend, class_name: 'Character'
end
