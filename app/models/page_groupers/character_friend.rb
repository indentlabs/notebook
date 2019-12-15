class CharacterFriend < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :character
  belongs_to :friend, class_name: Character.name
end
