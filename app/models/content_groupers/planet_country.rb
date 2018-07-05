class PlanetCountry < ActiveRecord
  belongs_to :user
  belongs_to :planet
  belongs_to :country
end
