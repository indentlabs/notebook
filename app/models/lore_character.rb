class LoreCharacter < ApplicationRecord
  belongs_to :lore
  belongs_to :character
  belongs_to :user
end
