class LandmarkCountry < ApplicationRecord
  belongs_to :user
  belongs_to :landmark
  belongs_to :country
end
