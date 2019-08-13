class TownCreature < ApplicationRecord
  belongs_to :user
  belongs_to :town
  belongs_to :creature
end
