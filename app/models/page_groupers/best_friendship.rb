class BestFriendship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :character
  belongs_to :best_friend, class_name: 'Character'
end
