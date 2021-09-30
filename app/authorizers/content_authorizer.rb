class ContentAuthorizer < ApplicationAuthorizer
  def readable_by? user
    return true if user && user.site_administrator?
    return true if ::PermissionService.user_owns_any_containing_universe?(user: user, content: resource)
    return true if ::PermissionService.user_owns_content?(user: user, content: resource)
    return true if ::PermissionService.content_is_public?(content: resource)
    return true if ::PermissionService.content_is_in_a_public_universe?(content: resource)
    return true if ::PermissionService.user_can_contribute_to_containing_universe?(user: user, content: resource)
    
    return false
  end

  def updatable_by? user
    return true if PermissionService.user_owns_any_containing_universe?(user: user, content: resource)
    return true if PermissionService.user_can_contribute_to_containing_universe?(user: user, content: resource)
    return true if [
      PermissionService.content_has_no_containing_universe?(content: resource),
      PermissionService.user_owns_content?(user: user, content: resource)
    ].all?
    
    return false
  end

  def deletable_by? user
    return true if PermissionService.user_owns_any_containing_universe?(user: user, content: resource)
    return true if [
      PermissionService.content_has_no_containing_universe?(content: resource),
      PermissionService.user_owns_content?(user: user, content: resource)
    ].all?
    return true if [
      PermissionService.user_can_contribute_to_containing_universe?(user: user, content: resource),
      PermissionService.user_owns_content?(user: user, content: resource)
    ].all?

    return false
  end
end
