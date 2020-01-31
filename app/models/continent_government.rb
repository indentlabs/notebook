class ContinentGovernment < ApplicationRecord
  belongs_to :continent
  belongs_to :government
  belongs_to :user, optional: true
end
