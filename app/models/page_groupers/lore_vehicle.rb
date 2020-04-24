class LoreVehicle < ApplicationRecord
  belongs_to :lore
  belongs_to :vehicle, optional: true
  
  belongs_to :user, optional: true
end
