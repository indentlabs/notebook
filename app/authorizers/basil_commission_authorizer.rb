# Authorization for Basil-generated images saved to a content page.
#
# Mirrors ImageUploadAuthorizer so both kinds of gallery image follow the same
# rule: anyone who can edit the page can manage its images.
class BasilCommissionAuthorizer < ApplicationAuthorizer
  def updatable_by?(user)
    ContentImageAuthorization.can_manage?(user, resource.entity)
  end

  def deletable_by?(user)
    updatable_by?(user)
  end
end
