class CharacterMagic < ActiveRecord
  belongs_to :character
  belongs_to :magic
  belongs_to :user
end
