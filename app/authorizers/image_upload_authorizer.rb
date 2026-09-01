# Authorization for images uploaded to a content page (ImageUpload).
#
# Anyone who can edit the page the image belongs to can manage the image:
# reorder it, set it as the cover, edit its notes, crop it, or delete it.
class ImageUploadAuthorizer < ApplicationAuthorizer
  def updatable_by?(user)
    ContentImageAuthorization.can_manage?(user, resource.content)
  end

  def deletable_by?(user)
    updatable_by?(user)
  end
end
