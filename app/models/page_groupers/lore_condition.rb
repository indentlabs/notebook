class LoreCondition < ApplicationRecord
  belongs_to :lore
  belongs_to :condition
  
  belongs_to :user, optional: true
end
