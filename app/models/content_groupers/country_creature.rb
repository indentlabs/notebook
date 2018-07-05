class CountryCreature < ActiveRecord
  belongs_to :user
  belongs_to :country
  belongs_to :creature
end
