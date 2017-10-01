class CoreContentAuthorizer < ContentAuthorizer
  def self.creatable_by? user
    [
      PermissionService.billing_plan_allows_core_content?(user: user)
    ].any?
  end
end
