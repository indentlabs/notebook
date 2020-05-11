class CharacterEnemy < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :character

  belongs_to :enemy, class_name: Character.name, optional: true
end
