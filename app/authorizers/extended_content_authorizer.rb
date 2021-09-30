class ExtendedContentAuthorizer < ContentAuthorizer
  def self.creatable_by?(user)
    return false unless user.present?
    return false if ENV.key?('CONTENT_BLACKLIST') && ENV['CONTENT_BLACKLIST'].split(',').include?(user.email)

    return true if PermissionService.billing_plan_allows_extended_content?(user: user)
    return true if PermissionService.user_can_collaborate_in_universe_that_allows_extended_content?(user: user)
    return true if user.active_promo_codes.any?
  end
end
