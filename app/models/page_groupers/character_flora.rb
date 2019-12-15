class CharacterFlora < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :character
  belongs_to :flora
end
