class GovernmentLeader < ApplicationRecord
  belongs_to :user
  belongs_to :government
  belongs_to :leader, class_name: Character.name
end
