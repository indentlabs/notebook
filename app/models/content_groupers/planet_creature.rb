class PlanetCreature < ApplicationRecord
  belongs_to :user
  belongs_to :planet
  belongs_to :creature
end
