class PlanetCreature < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :planet
  belongs_to :creature, optional: true
end
