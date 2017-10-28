class ExtendedContentAuthorizer < ContentAuthorizer
  def self.creatable_by? user
    return false if ENV['CONTENT_BLACKLIST'].split(',').include?(user.email)
    
  	return true
    [
      PermissionService.billing_plan_allows_extended_content?(user: user),
      PermissionService.user_can_collaborate_in_universe_that_allows_extended_content?(user: user)
    ].any?
  end
end
