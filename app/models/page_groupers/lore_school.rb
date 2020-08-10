class LoreSchool < ApplicationRecord
  belongs_to :lore
  belongs_to :school, optional: true
  
  belongs_to :user, optional: true
end
