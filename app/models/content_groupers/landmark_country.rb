class LandmarkCountry < ActiveRecord
  belongs_to :user
  belongs_to :landmark
  belongs_to :country
end
