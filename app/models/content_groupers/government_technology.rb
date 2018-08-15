class GovernmentTechnology < ApplicationRecord
  belongs_to :user
  belongs_to :government
  belongs_to :technology
end
