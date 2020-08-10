class LoreTradition < ApplicationRecord
  belongs_to :lore
  belongs_to :tradition, optional: true
  
  belongs_to :user, optional: true
end
