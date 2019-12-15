class CharacterLoveInterest < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true
  belongs_to :character
  belongs_to :love_interest, class_name: 'Character'
end
