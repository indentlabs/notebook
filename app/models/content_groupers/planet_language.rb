class PlanetLanguage < ApplicationRecord
  belongs_to :user
  belongs_to :planet
  belongs_to :language
end
