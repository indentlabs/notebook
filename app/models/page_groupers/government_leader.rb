class GovernmentLeader < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :government
  belongs_to :leader, class_name: Character.name, optional: true
end
