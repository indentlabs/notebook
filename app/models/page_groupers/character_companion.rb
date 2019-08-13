class CharacterCompanion < ApplicationRecord
  belongs_to :user
  belongs_to :character
  belongs_to :companion, class_name: Creature.name
end
