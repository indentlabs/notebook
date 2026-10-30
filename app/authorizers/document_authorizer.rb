class DocumentAuthorizer < ApplicationAuthorizer
  def self.creatable_by?(user)
    return false unless user.present?

    true
  end

  def readable_by?(user)
    # Anonymous viewers arrive as a blank User.new, whose nil id would otherwise match
    # ownerless documents and contributor invites nobody has claimed yet.
    user = nil if user && user.id.nil?

    return true if user && resource.user_id == user.id
    return true if user && user.site_administrator?

    # A password outranks the public universe and public book rules below. Readers who enter it get
    # the document page from DocumentsController, and everywhere else keeps treating it as private.
    return universe_member?(user) if resource.password_protected?

    return true if resource.privacy == 'public'
    return true if resource.universe.present? && resource.universe.privacy == 'public'
    return true if resource.readable_via_public_book?

    universe_member?(user)
  end

  def updatable_by?(user)
    [
      user && resource.user_id == user.id
    ].any?
  end

  def deletable_by?(user)
    [
      user && resource.user_id == user.id
    ].any?
  end

  private

  def universe_member?(user)
    return false unless user && resource.universe.present?

    resource.universe.user_id == user.id || resource.universe.contributors.pluck(:user_id).include?(user.id)
  end
end
