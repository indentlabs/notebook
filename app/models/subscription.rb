class Subscription < ActiveRecord
  belongs_to :user
  belongs_to :billing_plan
end
