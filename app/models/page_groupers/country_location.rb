class CountryLocation < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :country
  belongs_to :location, optional: true
end
