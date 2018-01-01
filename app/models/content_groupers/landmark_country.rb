class LandmarkCountry < ActiveRecord::Base
  belongs_to :user
  belongs_to :landmark
  belongs_to :country
end
