class LoreRace < ApplicationRecord
  belongs_to :lore
  belongs_to :race, optional: true
  
  belongs_to :user, optional: true
end
