class CharacterTechnology < ApplicationRecord
  belongs_to :user
  belongs_to :character
  belongs_to :technology
end
