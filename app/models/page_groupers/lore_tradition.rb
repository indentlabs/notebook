class LoreTradition < ApplicationRecord
  belongs_to :lore
  belongs_to :tradition
  
  belongs_to :user, optional: true
end
