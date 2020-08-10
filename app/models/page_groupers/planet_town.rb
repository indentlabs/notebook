class PlanetTown < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :planet
  belongs_to :town, optional: true
end
