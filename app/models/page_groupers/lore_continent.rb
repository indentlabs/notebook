class LoreContinent < ApplicationRecord
  belongs_to :lore
  belongs_to :continent, optional: true
  
  belongs_to :user, optional: true
end
