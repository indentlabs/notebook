class LoreGovernment < ApplicationRecord
  belongs_to :lore
  belongs_to :government
  
  belongs_to :user, optional: true
end
