class PlanetCountry < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :planet
  belongs_to :country
end
