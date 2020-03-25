class LoreVariation < ApplicationRecord
  belongs_to :lore
  belongs_to :variation, class_name: Lore.name
  
  belongs_to :user, optional: true
end
