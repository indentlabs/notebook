class ContinentGovernment < ApplicationRecord
  belongs_to :continent
  belongs_to :government, optional: true
  belongs_to :user, optional: true
end
