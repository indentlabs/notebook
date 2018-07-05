class PlanetTown < ActiveRecord
  belongs_to :user
  belongs_to :planet
  belongs_to :town
end
