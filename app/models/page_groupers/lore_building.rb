class LoreBuilding < ApplicationRecord
  belongs_to :lore
  belongs_to :building
  
  belongs_to :user, optional: true
end
