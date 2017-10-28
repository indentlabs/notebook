class CoreContentAuthorizer < ContentAuthorizer
  def self.creatable_by? user
    return false if ENV['CONTENT_BLACKLIST'].split(',').include?(user.email)
  	return true
    [
      PermissionService.billing_plan_allows_core_content?(user: user)
    ].any?
  end
end
