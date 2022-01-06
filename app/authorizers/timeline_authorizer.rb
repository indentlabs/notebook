class TimelineAuthorizer < ContentAuthorizer
  def self.creatable_by?(user)
    return false unless user.present?
    return false if ENV.key?('CONTENT_BLACKLIST') && ENV['CONTENT_BLACKLIST'].split(',').include?(user.email)

    return true if user.on_premium_plan?
  end

  def readable_by?(user)
    return true if resource.privacy == 'public'
    return true if user && resource.user_id == user.id
    return true if resource.universe.present? && resource.universe.privacy == 'public'
    return true if user && resource.universe.present? && resource.universe.user_id == user.id
    return true if user && resource.universe.present? && resource.universe.contributors.pluck(:user_id).include?(user.id)
    return true if user && user.site_administrator?

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
