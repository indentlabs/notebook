class LorePlanet < ApplicationRecord
  belongs_to :lore
  belongs_to :planet, optional: true
  
  belongs_to :user, optional: true
end
