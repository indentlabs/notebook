class UniverseCoreContentAuthorizer < CoreContentAuthorizer
  def self.creatable_by? user
    user.universes.count < user.active_billing_plans.map(&:universe_limit).max
  end

  def readable_by? user
    [
      resource.user_id == user.id,
      resource.privacy == 'public'
 	].any?
  end

  def updatable_by? user
  	resource.user_id == user.id
  end

  def deletable_by? user
  	resource.user_id == user.id
  end
end
