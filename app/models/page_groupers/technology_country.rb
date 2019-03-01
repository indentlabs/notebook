class TechnologyCountry < ApplicationRecord
  belongs_to :user
  belongs_to :technology
  belongs_to :country
end
