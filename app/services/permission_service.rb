# A helper for more human-readable logic clauses to be used in permissions
class PermissionService < Service
  def self.user_has_fewer_owned_universes_than_plan_limit?(user:)
    user.universes.count < (user.active_billing_plans.map(&:universe_limit).max || 5)
  end

  def self.user_owns_content?(user:, content:)
    content.user == user
  end

  def self.user_owns_any_containing_universe?(user:, content:)
    content.respond_to?(:universe) && content.universe.present? && user_owns_content?(user: user, content: content.universe)
  end

  def self.user_can_contribute_to_universe?(user:, universe:)
    user.present? && user.contributable_universes.pluck(:id).include?(universe.id)
  end

  def self.content_is_public?(content:)
    content.respond_to?(:privacy) && content.privacy == 'public'
  end

  def self.content_is_in_a_public_universe?(content:)
    content.respond_to?(:universe) && content.universe.present? && self.content_is_public?(content: content.universe)
  end

  def self.user_can_contribute_to_containing_universe?(user:, content:)
    return false if user.nil?
    return true if [AttributeCategory, AttributeField, Attribute].include?(content.class) #todo audit this
    content.universe.present? && user.contributable_universes.pluck(:id).include?(content.universe.id)
  end

  def self.content_has_no_containing_universe?(content:)
    content.universe_field_value.nil?
  end

  def self.user_is_on_premium_plan?(user:)
    user.on_premium_plan?
  end

  def self.billing_plan_allows_core_content?(user:)
    active_billing_plans = user.active_billing_plans
    active_billing_plans.empty? || active_billing_plans.any?(&:allows_core_content)
  end

  def self.billing_plan_allows_extended_content?(user:)
    # todo remove second clause will billing plans are fixed
    #user.active_billing_plans.any?(&:allows_extended_content) ||
    BillingPlan::PREMIUM_IDS.include?(user.selected_billing_plan_id)
  end

  def self.user_can_collaborate_in_universe_that_allows_extended_content?(user:)
    user.contributable_universes.any? do |universe|
      billing_plan_allows_extended_content?(user: universe.user)
    end
  end

  def self.billing_plan_allows_collective_content?(user:)
    #user.active_billing_plans.any?(&:allows_collective_content) ||
    BillingPlan::PREMIUM_IDS.include?(user.selected_billing_plan_id)
  end

  def self.user_can_collaborate_in_universe_that_allows_collective_content?(user:)
    user.contributable_universes.any? do |universe|
      billing_plan_allows_collective_content?(user: universe.user)
    end
  end

  def self.user_has_active_promotion_for_this_content_type(user:, content_type:)
    user.active_promotions.pluck(:content_type).include?(content_type)
  end

end
