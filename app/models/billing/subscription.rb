class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :billing_plan
end
