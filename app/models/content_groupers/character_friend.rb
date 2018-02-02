class CharacterFriend < ActiveRecord::Base
  belongs_to :user
  belongs_to :character
  belongs_to :friend, class_name: Character.name
end
