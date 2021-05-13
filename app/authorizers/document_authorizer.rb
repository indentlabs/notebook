class DocumentAuthorizer < ApplicationAuthorizer
  def self.creatable_by?(user)
    true
  end

  def readable_by?(user)
    [
      resource.user_id == user.id,
      resource.privacy == 'public',
      resource.universe.present? && resource.universe.privacy == 'public',
      resource.universe.present? && resource.universe.contributors.pluck(:user_id).include?(user.id),
      resource.universe.present? && resource.universe.user_id == user.id
    ].any?
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
