class ExtendedContentAuthorizer < ContentAuthorizer
  def self.creatable_by? user
    user.active_billing_plans.any? { |plan| plan.allows_extended_content }
  end
end
