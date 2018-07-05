class CharacterTechnology < ActiveRecord
  belongs_to :user
  belongs_to :character
  belongs_to :technology
end
