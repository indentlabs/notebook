class CharacterMagic < ActiveRecord::Base
  belongs_to :character
  belongs_to :magic
  belongs_to :user
end
