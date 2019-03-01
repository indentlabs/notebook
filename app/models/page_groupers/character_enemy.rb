class CharacterEnemy < ApplicationRecord
  belongs_to :character
  belongs_to :user
  belongs_to :enemy, class_name: Character.name
end
