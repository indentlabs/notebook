class LoreRace < ApplicationRecord
  belongs_to :lore
  belongs_to :race
  
  belongs_to :user, optional: true
end
