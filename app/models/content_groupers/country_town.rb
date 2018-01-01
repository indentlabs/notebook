class CountryTown < ActiveRecord::Base
  belongs_to :user
  belongs_to :country
  belongs_to :town
end
