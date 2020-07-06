class CharacterMagic < ApplicationRecord
  belongs_to :character
  belongs_to :magic, optional: true
  belongs_to :user, optional: true
end
