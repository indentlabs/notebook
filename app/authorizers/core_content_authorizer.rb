class CoreContentAuthorizer < ContentAuthorizer
  def self.readable_by?(user)
    # Check public content first - these should be accessible to anyone
    return true if resource.privacy == 'public'
    return true if resource.try(:universe).try(:privacy) == 'public'
    
    # For private content, require a user
    return false if user.nil?
    
    # Check user-specific permissions
    return true if resource.user == user # PermissionService.user_owns_content?()

    false
  end

  def self.creatable_by?(user)
    return false unless user.present?
    return false if ENV.key?('CONTENT_BLACKLIST') && ENV['CONTENT_BLACKLIST'].split(',').include?(user.email)
    
    return true # All billing plans support core content right now
    # [
    #   PermissionService.billing_plan_allows_core_content?(user: user)
    # ].any?
  end
end
