class ContentAuthorizer < ApplicationAuthorizer
  def readable_by? user
    [
      PermissionService.user_owns_any_containing_universe?(user: user, content: resource),
      PermissionService.user_owns_content?(user: user, content: resource),
      PermissionService.content_is_public?(content: resource),
      PermissionService.content_is_in_a_public_universe?(content: resource),
      PermissionService.user_can_contribute_to_containing_universe?(user: user, content: resource)
    ].any?
  end

  def updatable_by? user
    [
      PermissionService.user_owns_any_containing_universe?(user: user, content: resource),
      PermissionService.user_can_contribute_to_containing_universe?(user: user, content: resource),
      [
        PermissionService.content_has_no_containing_universe?(content: resource),
        PermissionService.user_owns_content?(user: user, content: resource)
      ].all?
    ].any?
  end

  def deletable_by? user
    [
      PermissionService.user_owns_any_containing_universe?(user: user, content: resource),
      [
        PermissionService.content_has_no_containing_universe?(content: resource),
        PermissionService.user_owns_content?(user: user, content: resource)
      ].all?,
      [
        PermissionService.user_can_contribute_to_containing_universe?(user: user, content: resource),
        PermissionService.user_owns_content?(user: user, content: resource)
      ].all?
    ].any?
  end
end
