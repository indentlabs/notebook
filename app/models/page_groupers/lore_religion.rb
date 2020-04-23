class LoreReligion < ApplicationRecord
  belongs_to :lore
  belongs_to :religion
  
  belongs_to :user, optional: true
end
