class CountryGovernment < ApplicationRecord
  belongs_to :country
  belongs_to :government, optional: true
  belongs_to :user, optional: true
end
