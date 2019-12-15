class TechnologyCountry < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :technology
  belongs_to :country
end
