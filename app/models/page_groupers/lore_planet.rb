class LorePlanet < ApplicationRecord
  belongs_to :lore
  belongs_to :planet
  
  belongs_to :user, optional: true
end
