class PlanetRace < ActiveRecord
  belongs_to :user
  belongs_to :planet
  belongs_to :race
end
