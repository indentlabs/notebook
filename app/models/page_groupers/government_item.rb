class GovernmentItem < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :government
  belongs_to :item
end
