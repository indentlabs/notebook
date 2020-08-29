class CoreContentAuthorizer < ContentAuthorizer
  def self.creatable_by? user
    return false if ENV.key?('CONTENT_BLACKLIST') && ENV['CONTENT_BLACKLIST'].split(',').include?(user.email)
    
    return true # All billing plans support core content right now
    # [
    #   PermissionService.billing_plan_allows_core_content?(user: user)
    # ].any?
  end
end
