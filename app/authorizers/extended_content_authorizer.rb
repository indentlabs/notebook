class ExtendedContentAuthorizer < ContentAuthorizer
  def self.creatable_by? user
    user.active_billing_plans.any? { |plan| plan.allows_extended_content } || user.selected_billing_plan_id == 2
  end
end
