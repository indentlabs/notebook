class LoreBuilding < ApplicationRecord
  belongs_to :lore
  belongs_to :buildsing
  belongs_to :user
end
