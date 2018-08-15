class TechnologyPlanet < ApplicationRecord
  belongs_to :user
  belongs_to :technology
  belongs_to :planet
end
