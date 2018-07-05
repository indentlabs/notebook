class CharacterFlora < ApplicationRecord
  belongs_to :user
  belongs_to :character
  belongs_to :flora
end
