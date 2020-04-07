class LoreSchool < ApplicationRecord
  belongs_to :lore
  belongs_to :school
  
  belongs_to :user, optional: true
end
