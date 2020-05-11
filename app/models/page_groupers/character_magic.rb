class CharacterMagic < ApplicationRecord
  belongs_to :character
  belongs_to :magic
  belongs_to :user, optional: true, optional: true
end
