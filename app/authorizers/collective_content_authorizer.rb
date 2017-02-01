class CollectiveContentAuthorizer < ContentAuthorizer
  def self.creatable_by? user
    user.active_billing_plans.any? { |plan| plan.allows_collective_content }
  end
end
