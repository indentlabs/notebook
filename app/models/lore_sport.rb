class LoreSport < ApplicationRecord
  belongs_to :lore
  belongs_to :sport
  belongs_to :user
end
