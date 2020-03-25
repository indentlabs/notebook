class LoreCountry < ApplicationRecord
  belongs_to :lore
  belongs_to :country
  belongs_to :user
end
