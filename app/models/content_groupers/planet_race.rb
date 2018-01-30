class PlanetRace < ActiveRecord::Base
  belongs_to :user
  belongs_to :planet
  belongs_to :race
end
