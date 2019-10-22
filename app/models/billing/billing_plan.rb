class BillingPlan < ApplicationRecord
  PREMIUM_IDS = [2, 3, 4, 5, 6]

  def premium_plan?
    PREMIUM_IDS.include?(self.id)
  end
end
