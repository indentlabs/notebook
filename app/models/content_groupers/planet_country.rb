class PlanetCountry < ApplicationRecord
  belongs_to :user
  belongs_to :planet
  belongs_to :country
end
