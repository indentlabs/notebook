class LoreVehicle < ApplicationRecord
  belongs_to :lore
  belongs_to :vehicle
  
  belongs_to :user, optional: true
end
