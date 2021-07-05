class UniverseCoreContentAuthorizer < CoreContentAuthorizer
  def self.creatable_by? user
    return false unless user.present?
    return false if ENV.key?('CONTENT_BLACKLIST') && ENV['CONTENT_BLACKLIST'].split(',').include?(user.email)

    return true if PermissionService.user_has_fewer_owned_universes_than_plan_limit?(user: user)
    return true if PermissionService.user_is_on_premium_plan?(user: user)

    return false
  end

  def readable_by? user
    return true if PermissionService.content_is_public?(content: resource)
    return true if PermissionService.user_owns_content?(user: user, content: resource)
    return true if PermissionService.user_can_contribute_to_universe?(user: user, universe: resource)

    return false
  end

  def updatable_by? user
    return true if PermissionService.user_owns_content?(user: user, content: resource)
    return true if PermissionService.user_can_contribute_to_universe?(user: user, universe: resource)

    return false
  end

  def deletable_by? user
    [
      PermissionService.user_owns_content?(user: user, content: resource)
    ].any?
  end
end
