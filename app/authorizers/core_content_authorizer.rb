class CoreContentAuthorizer < ContentAuthorizer
  def self.creatable_by? user
    user.active_billing_plans.any? { |plan| plan.allows_core_content }
  end
end
