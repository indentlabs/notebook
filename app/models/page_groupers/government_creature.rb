class GovernmentCreature < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :government
  belongs_to :creature
end
