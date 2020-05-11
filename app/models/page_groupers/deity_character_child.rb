class DeityCharacterChild < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :deity
  belongs_to :character_child, class_name: Character.name, optional: true
end
