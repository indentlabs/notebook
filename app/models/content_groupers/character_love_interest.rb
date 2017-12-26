class CharacterLoveInterest < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user
  belongs_to :character
  belongs_to :love_interest, class_name: 'Character'
end
