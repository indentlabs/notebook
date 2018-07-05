class PlanetLanguage < ActiveRecord
  belongs_to :user
  belongs_to :planet
  belongs_to :language
end
