class DocumentAuthorizer < ApplicationAuthorizer
  def self.creatable_by?(user)
    true
  end

  def readable_by?(user)
    return true if resource.user_id == user.id
    return true if resource.privacy == 'public'
    return true if resource.universe.present? && resource.universe.privacy == 'public'
    return true if resource.universe.present? && resource.universe.contributors.pluck(:user_id).include?(user.id)
    return true if resource.universe.present? && resource.universe.user_id == user.id

    return false
  end

  def updatable_by?(user)
    [
      resource.user_id == user.id
    ].any?
  end

  def deletable_by?(user)
    [
      resource.user_id == user.id
    ].any?
  end
end
