class LoreBeliever < ApplicationRecord
  belongs_to :lore
  belongs_to :user
end
