class PlanetLocation < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :planet
  belongs_to :location, optional: true
end
