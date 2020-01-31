class PlanetContinent < ApplicationRecord
  belongs_to :planet
  belongs_to :continent
  belongs_to :user, optional: true
end
