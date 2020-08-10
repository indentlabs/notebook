class CharacterItem < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :character
  belongs_to :item, optional: true
end
