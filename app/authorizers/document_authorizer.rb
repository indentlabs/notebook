class DocumentAuthorizer < ApplicationAuthorizer
  def readable_by?(user)
    [
      resource.user_id == user.id
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
