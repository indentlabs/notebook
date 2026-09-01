# Shared rule for who may manage the images attached to a piece of content.
#
# Used by ImageUploadAuthorizer and BasilCommissionAuthorizer, and by the
# gallery endpoints that act on a content page rather than a single image
# (sorting, uploading).
module ContentImageAuthorization
  def self.can_manage?(user, content)
    return false if user.nil? || content.nil?
    return true  if user.respond_to?(:site_administrator?) && user.site_administrator?
    return true  if content.respond_to?(:user_id) && content.user_id == user.id

    content.respond_to?(:updatable_by?) && content.updatable_by?(user)
  end
end
