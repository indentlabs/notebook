class LoreContinent < ApplicationRecord
  belongs_to :lore
  belongs_to :continent
  belongs_to :user
end
