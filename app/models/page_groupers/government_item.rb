class GovernmentItem < ApplicationRecord
  belongs_to :user
  belongs_to :government
  belongs_to :item
end
