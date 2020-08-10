class LoreCountry < ApplicationRecord
  belongs_to :lore
  belongs_to :country, optional: true
  
  belongs_to :user, optional: true
end
