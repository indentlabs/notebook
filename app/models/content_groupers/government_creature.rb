class GovernmentCreature < ActiveRecord
  belongs_to :user
  belongs_to :government
  belongs_to :creature
end
