class DocumentAuthorizer < ApplicationAuthorizer
  def self.creatable_by?(user)
    return false unless user.present?

    true
  end

  def readable_by?(user)
    return true if user && resource.user_id == user.id
    return true if user && user.site_administrator?
    return true if resource.privacy == 'public'
    return true if resource.universe.present? && resource.universe.privacy == 'public'
    return true if user && resource.universe.present? && resource.universe.contributors.pluck(:user_id).include?(user.id)
    return true if user && resource.universe.present? && resource.universe.user_id == user.id

    return false
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
end
