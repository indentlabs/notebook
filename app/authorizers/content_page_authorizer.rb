class ContentPageAuthorizer < CoreContentAuthorizer
  def self.creatable_by?(user)
    return false unless user.present?
    return false if ENV.key?('CONTENT_BLACKLIST') && ENV['CONTENT_BLACKLIST'].split(',').include?(user.email)

    if resource.page_type == 'Universe'
      return true if PermissionService.user_has_fewer_owned_universes_than_plan_limit?(user: user)

    else
      is_premium_page = Rails.application.config.content_types[:premium].include?(resource.page_type)
      return true if !is_premium_page
      return true if is_premium_page && PermissionService.user_is_on_premium_plan?(user: user)
    end

    return false
  end

  def readable_by?(user)
    return true if PermissionService.content_is_public?(content: resource)
    return true if PermissionService.user_owns_content?(user: user, content: resource)

    if resource.page_type == 'Universe'
      return true if PermissionService.user_can_contribute_to_universe?(user: user, universe: resource)
    else
      return true if PermissionService.user_can_contribute_to_containing_universe?(user: user, content: resource)
    end

    return false
  end

  def updatable_by?(user)
    return true if PermissionService.user_owns_content?(user: user, content: resource)
    
    if resource.page_type == 'Universe'
      return true if PermissionService.user_can_contribute_to_universe?(user: user, universe: resource)
    else
      return true if PermissionService.user_can_contribute_to_containing_universe?(user: user, content: resource)
    end

    return false
  end

  def deletable_by?(user)
    [
      PermissionService.user_owns_content?(user: user, content: resource)
    ].any?
  end
end
