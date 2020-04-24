class TownCreature < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :town
  belongs_to :creature, optional: true
end
