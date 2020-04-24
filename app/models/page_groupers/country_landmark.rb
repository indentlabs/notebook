class CountryLandmark < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :country
  belongs_to :landmark, optional: true
end
