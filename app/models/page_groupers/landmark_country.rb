class LandmarkCountry < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :landmark
  belongs_to :country
end
