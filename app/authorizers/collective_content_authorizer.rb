class CollectiveContentAuthorizer < ContentAuthorizer
  def self.creatable_by? user
  	return true
    [
      PermissionService.billing_plan_allows_collective_content?(user: user),
      PermissionService.user_can_collaborate_in_universe_that_allows_collective_content?(user: user)
    ].any?
  end
end
