class CountryFlora < ApplicationRecord
  belongs_to :user
  belongs_to :country
  belongs_to :flora
end
