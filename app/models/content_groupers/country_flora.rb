class CountryFlora < ActiveRecord
  belongs_to :user
  belongs_to :country
  belongs_to :flora
end
