class CharacterCompanion < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :character

  belongs_to :companion, class_name: Creature.name, optional: true
end
