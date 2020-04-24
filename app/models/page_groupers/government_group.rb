class GovernmentGroup < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :government
  belongs_to :group, optional: true
end
