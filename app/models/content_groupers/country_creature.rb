class CountryCreature < ActiveRecord::Base
  belongs_to :user
  belongs_to :country
  belongs_to :creature
end
