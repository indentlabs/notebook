class CountryLandmark < ActiveRecord
  belongs_to :user
  belongs_to :country
  belongs_to :landmark
end
