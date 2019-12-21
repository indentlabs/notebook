class DeityCharacterParent < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :deity
  belongs_to :character_parent, class_name: Character.name
end
