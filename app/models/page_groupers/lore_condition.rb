class LoreCondition < ApplicationRecord
  belongs_to :lore
  belongs_to :condition, optional: true
  
  belongs_to :user, optional: true
end
