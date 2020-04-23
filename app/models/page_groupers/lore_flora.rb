class LoreFlora < ApplicationRecord
  belongs_to :lore
  belongs_to :flora
  
  belongs_to :user, optional: true
end
