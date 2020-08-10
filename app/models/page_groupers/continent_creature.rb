class ContinentCreature < ApplicationRecord
  belongs_to :continent
  belongs_to :creature, optional: true
  belongs_to :user, optional: true
end
