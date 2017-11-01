class CoreContentAuthorizer < ContentAuthorizer
  def self.creatable_by? user
    return false if ENV.key?('CONTENT_BLACKLIST') && ENV['CONTENT_BLACKLIST'].split(',').include?(user.email)

    [
      PermissionService.billing_plan_allows_core_content?(user: user)
    ].any?
  end
end
