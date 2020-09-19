class CoreContentAuthorizer < ContentAuthorizer
  def self.readable_by?(user)
    return true if resource.user == user # PermissionService.user_owns_content?()
    return true if resource.privacy == 'public'
    return true if resource.try(:universe).try(:privacy) == 'public'

    false
  end

  def self.creatable_by?(user)
    return false if ENV.key?('CONTENT_BLACKLIST') && ENV['CONTENT_BLACKLIST'].split(',').include?(user.email)

    [
      PermissionService.billing_plan_allows_core_content?(user: user)
    ].any?
  end
end
