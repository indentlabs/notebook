# A helper for more human-readable logic clauses to be used in permissions
class PermissionService < Service
  def self.user_has_fewer_owned_universes_than_plan_limit?(user:)
    user.universes.count < (user.active_billing_plans.map(&:universe_limit).max || 5)
  end

  def self.user_owns_content?(user:, content:)
    content.user && user && content.try(:user_id) == user.try(:id)
  end

  def self.user_owns_any_containing_universe?(user:, content:)
    content.respond_to?(:universe) && content.universe.present? && user_owns_content?(user: user, content: content.universe)
  end

  # Read-level access: the user is a contributor (of any role) to this universe
  def self.user_can_contribute_to_universe?(user:, universe:)
    user.present? && user.contributable_universes.pluck(:id).include?(universe.id)
  end

  # Edit-level access: the user is a Full Contributor or Editor in this universe
  def self.user_can_edit_universe_content?(user:, universe:)
    user.present? && user.editable_universe_ids.include?(universe.id)
  end

  # Create-level access: the user is a Full Contributor in this universe
  def self.user_can_create_universe_content?(user:, universe:)
    user.present? && user.creatable_universe_ids.include?(universe.id)
  end

  def self.content_is_public?(content:)
    content.respond_to?(:privacy) && content.privacy == 'public'
  end

  def self.content_is_in_a_public_universe?(content:)
    content.respond_to?(:universe) && content.universe.present? && self.content_is_public?(content: content.universe)
  end

  # Read-level access to the universe containing this content (contributor of any role)
  def self.user_can_contribute_to_containing_universe?(user:, content:)
    # Early return if no user is provided
    return false if user.nil?

    # Special case for attribute-related content
    return true if [AttributeCategory, AttributeField, Attribute].include?(content.class) #todo audit this

    # Handle cases where content might not have a universe_id
    return false if content.universe_id.nil?

    # Check if user can contribute to this universe
    return true if user.respond_to?(:contributable_universe_ids) && user.contributable_universe_ids.include?(content.universe_id)
    return true if user.respond_to?(:universes) && user.universes.pluck(:id).include?(content.universe_id)

    return false
  end

  # Edit-level access to the universe containing this content (Full Contributor or Editor)
  def self.user_can_edit_containing_universe_content?(user:, content:)
    return false if user.nil?

    # Special case for attribute-related content, mirroring user_can_contribute_to_containing_universe?
    return true if [AttributeCategory, AttributeField, Attribute].include?(content.class) #todo audit this

    return false if content.universe_id.nil?

    return true if user.respond_to?(:editable_universe_ids) && user.editable_universe_ids.include?(content.universe_id)
    return true if user.respond_to?(:universes) && user.universes.pluck(:id).include?(content.universe_id)

    return false
  end

  def self.content_has_no_containing_universe?(content:)
    content.universe.nil?
  end

  # Whether the given attribute field (and its value) on the given content page is
  # visible to the given viewer. This is the single source of truth for field-level
  # privacy; see AttributeField::VISIBILITIES for the levels.
  def self.attribute_field_visible_to?(field:, content:, viewer:)
    case field.effective_privacy
    when 'private'
      # Only the page owner can see private fields
      user_owns_content?(user: viewer, content: content)
    when 'contributors'
      return false if viewer.nil?
      return true if viewer.try(:site_administrator?)
      return true if user_owns_content?(user: viewer, content: content)
      return true if user_owns_any_containing_universe?(user: viewer, content: content)

      if content.is_a?(Universe)
        user_can_contribute_to_universe?(user: viewer, universe: content)
      else
        content.respond_to?(:universe_id) &&
          content.universe_id.present? &&
          user_can_contribute_to_containing_universe?(user: viewer, content: content)
      end
    else # 'public'
      true
    end
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
    # Only universes the user can create new content in count here, since this
    # permission gates creating extended content types
    user.creatable_universes.any? do |universe|
      universe.user.on_premium_plan?
#      billing_plan_allows_extended_content?(user: universe.user) || user_has_active_promotion_for_this_content_type(user: universe.user, content_type: Universe)
    end
  end

  def self.billing_plan_allows_collective_content?(user:)
    #user.active_billing_plans.any?(&:allows_collective_content) ||
    BillingPlan::PREMIUM_IDS.include?(user.selected_billing_plan_id)
  end

  def self.user_can_collaborate_in_universe_that_allows_collective_content?(user:)
    user.creatable_universes.any? do |universe|
      universe.user.on_premium_plan?
#      billing_plan_allows_collective_content?(user: universe.user) || user_has_active_promotion_for_this_content_type(user: universe.user, content_type: Universe)
    end
  end

  def self.user_has_active_promotion_for_this_content_type(user:, content_type:)
    user.active_promotions.pluck(:content_type).include?(content_type)
  end

end
