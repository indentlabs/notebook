class CountryGovernment < ActiveRecord::Base
  belongs_to :country
  belongs_to :government
  belongs_to :user
end
