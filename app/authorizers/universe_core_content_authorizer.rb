class UniverseCoreContentAuthorizer < CoreContentAuthorizer
  def self.creatable_by? user
    if BillingPlan.find_by(stripe_plan_id: 'free-for-life')
      return true if user.selected_billing_plan_id == BillingPlan.find_by(stripe_plan_id: 'free-for-life').id
    end

    user.universes.count < (user.active_billing_plans.map(&:universe_limit).max || 5)
  end

  def readable_by? user
    [
      resource.user_id == user.id,
      resource.privacy == 'public',
      user.contributable_universes.pluck(:id).include?(resource.id)
 	  ].any?
  end

  def updatable_by? user
    [
    	resource.user_id == user.id,
      user.contributable_universes.pluck(:id).include?(resource.id)
    ].any?
  end

  def deletable_by? user
  	resource.user_id == user.id
  end
end
