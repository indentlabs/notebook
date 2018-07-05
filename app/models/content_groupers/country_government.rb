class CountryGovernment < ActiveRecord
  belongs_to :country
  belongs_to :government
  belongs_to :user
end
