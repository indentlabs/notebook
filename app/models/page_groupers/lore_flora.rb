class LoreFlora < ApplicationRecord
  belongs_to :lore
  belongs_to :flora, optional: true
  
  belongs_to :user, optional: true
end
