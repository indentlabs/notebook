class ContinentCreature < ApplicationRecord
  belongs_to :continent
  belongs_to :creature
  belongs_to :user, optional: true
end
