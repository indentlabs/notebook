class CoreContentAuthorizer < ContentAuthorizer
  def self.creatable_by? user
    active_billing_plans = user.active_billing_plans

    active_billing_plans.empty? || active_billing_plans.any? { |plan| plan.allows_core_content }
  end
end
