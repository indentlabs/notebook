class LoreBuilding < ApplicationRecord
  belongs_to :lore
  belongs_to :building, optional: true
  
  belongs_to :user, optional: true
end
