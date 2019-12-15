class DeityCharacterPartner < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :deity
  belongs_to :character_partner, class_name: Character.name
end
