class BookAuthorizer < ApplicationAuthorizer
  def self.creatable_by?(user)
    return false unless user.present?
    return false if ENV.key?('CONTENT_BLACKLIST') && ENV['CONTENT_BLACKLIST'].split(',').include?(user.email)

    true # Free for all users
  end

  def readable_by?(user)
    return true if resource.privacy == 'public'
    return true if user && resource.user_id == user.id
    return true if resource.universe.present? && resource.universe.privacy == 'public'
    return true if user && resource.universe.present? && resource.universe.user_id == user.id
    return true if user && resource.universe.present? && resource.universe.contributors.pluck(:user_id).include?(user.id)
    return true if user && user.site_administrator?

    false
  end

  def updatable_by?(user)
    return true if user && resource.user_id == user.id
    return true if user && resource.universe.present? && resource.universe.contributors.pluck(:user_id).include?(user.id)

    false
  end

  def deletable_by?(user)
    user && resource.user_id == user.id
  end
end
