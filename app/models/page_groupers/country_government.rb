class CountryGovernment < ApplicationRecord
  belongs_to :country
  belongs_to :government
  belongs_to :user, optional: true
end
