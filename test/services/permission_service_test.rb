require 'test_helper'

class PermissionServiceTest < ActiveSupport::TestCase
  
  def setup
    # Use existing fixture users
    @free_user = users(:one)
    @premium_user = users(:two)
    
    # Set billing plan IDs
    @free_user.update(selected_billing_plan_id: 1)  # Free plan
    @premium_user.update(selected_billing_plan_id: 4) # Premium plan
    
    # Create test content using existing fixtures
    @test_character = characters(:one)
    @other_character = characters(:two)
    
    # Ensure proper associations
    @test_character.update(user_id: @free_user.id, privacy: 'public')
    @other_character.update(user_id: @premium_user.id, privacy: 'private')
  end

  # Test user_owns_content?
  test "user_owns_content returns true for owned content" do
    assert PermissionService.user_owns_content?(user: @free_user, content: @test_character)
    assert PermissionService.user_owns_content?(user: @premium_user, content: @other_character)
  end

  test "user_owns_content returns false for non-owned content" do
    refute PermissionService.user_owns_content?(user: @free_user, content: @other_character)
    refute PermissionService.user_owns_content?(user: @premium_user, content: @test_character)
  end

  test "user_owns_content handles nil user safely" do
    refute PermissionService.user_owns_content?(user: nil, content: @test_character)
  end

  test "user_owns_content handles nil content by raising error" do
    # The method expects content to respond to .user, so nil content should raise NoMethodError
    assert_raises(NoMethodError) do
      PermissionService.user_owns_content?(user: @free_user, content: nil)
    end
  end

  test "user_owns_content handles content without user_id" do
    # Create a stub content object without user_id
    content_without_user = OpenStruct.new(user: nil)
    content_without_user.define_singleton_method(:try) { |method| nil if method == :user_id }
    
    refute PermissionService.user_owns_content?(user: @free_user, content: content_without_user)
  end

  # Test user_can_contribute_to_universe?
  test "user_can_contribute_to_universe handles nil user" do
    # Create a mock universe for testing
    universe = OpenStruct.new(id: 1)
    refute PermissionService.user_can_contribute_to_universe?(user: nil, universe: universe)
  end

  test "user_can_contribute_to_universe returns false without contributable universes" do
    # Create a mock universe 
    universe = OpenStruct.new(id: 999) # ID that won't match any associations
    refute PermissionService.user_can_contribute_to_universe?(user: @free_user, universe: universe)
  end

  # Test content_is_public?
  test "content_is_public returns true for public content" do
    @test_character.update(privacy: 'public')
    assert PermissionService.content_is_public?(content: @test_character)
  end

  test "content_is_public returns false for private content" do
    @other_character.update(privacy: 'private')
    refute PermissionService.content_is_public?(content: @other_character)
  end

  test "content_is_public handles content without privacy method" do
    content_without_privacy = OpenStruct.new
    content_without_privacy.define_singleton_method(:respond_to?) { |method| false if method == :privacy }
    
    refute PermissionService.content_is_public?(content: content_without_privacy)
  end

  # Test user_can_contribute_to_containing_universe?
  test "user_can_contribute_to_containing_universe handles nil user" do
    refute PermissionService.user_can_contribute_to_containing_universe?(user: nil, content: @test_character)
  end

  test "user_can_contribute_to_containing_universe handles content without universe_id" do
    content_without_universe_id = OpenStruct.new(universe_id: nil)
    refute PermissionService.user_can_contribute_to_containing_universe?(user: @free_user, content: content_without_universe_id)
  end

  test "user_can_contribute_to_containing_universe returns true for attribute-related content" do
    # Mock attribute content classes
    stub_const('AttributeCategory', Class.new)
    stub_const('AttributeField', Class.new) 
    stub_const('Attribute', Class.new)
    
    attribute_category = OpenStruct.new(class: AttributeCategory)
    attribute_field = OpenStruct.new(class: AttributeField)
    attribute = OpenStruct.new(class: Attribute)
    
    assert PermissionService.user_can_contribute_to_containing_universe?(user: @free_user, content: attribute_category)
    assert PermissionService.user_can_contribute_to_containing_universe?(user: @free_user, content: attribute_field)
    assert PermissionService.user_can_contribute_to_containing_universe?(user: @free_user, content: attribute)
  end

  # Test content_has_no_containing_universe?
  test "content_has_no_containing_universe returns true when universe is nil" do
    content_without_universe = OpenStruct.new(universe: nil)
    assert PermissionService.content_has_no_containing_universe?(content: content_without_universe)
  end

  test "content_has_no_containing_universe returns false when universe is present" do
    content_with_universe = OpenStruct.new(universe: "some_universe")
    refute PermissionService.content_has_no_containing_universe?(content: content_with_universe)
  end

  # Test user_is_on_premium_plan?
  test "user_is_on_premium_plan returns true for premium users" do
    assert PermissionService.user_is_on_premium_plan?(user: @premium_user)
  end

  test "user_is_on_premium_plan returns false for free users" do
    refute PermissionService.user_is_on_premium_plan?(user: @free_user)
  end

  # Test billing_plan_allows_core_content?
  test "billing_plan_allows_core_content returns true for all users with active plans" do
    assert PermissionService.billing_plan_allows_core_content?(user: @free_user)
    assert PermissionService.billing_plan_allows_core_content?(user: @premium_user)
  end

  test "billing_plan_allows_core_content returns true for users without active billing plans" do
    user_without_plan = User.create!(
      email: 'noplan@example.com',
      password: 'password123',
      selected_billing_plan_id: nil
    )
    assert PermissionService.billing_plan_allows_core_content?(user: user_without_plan)
  end

  # Test billing_plan_allows_extended_content?
  test "billing_plan_allows_extended_content returns true for premium users" do
    assert PermissionService.billing_plan_allows_extended_content?(user: @premium_user)
  end

  test "billing_plan_allows_extended_content returns false for free users" do
    refute PermissionService.billing_plan_allows_extended_content?(user: @free_user)
  end

  # Test user_can_collaborate_in_universe_that_allows_extended_content?
  test "user_can_collaborate_in_universe_that_allows_extended_content returns false when no premium collaborations" do
    refute PermissionService.user_can_collaborate_in_universe_that_allows_extended_content?(user: @free_user)
  end

  # Test billing_plan_allows_collective_content?
  test "billing_plan_allows_collective_content returns true for premium users" do
    assert PermissionService.billing_plan_allows_collective_content?(user: @premium_user)
  end

  test "billing_plan_allows_collective_content returns false for free users" do
    refute PermissionService.billing_plan_allows_collective_content?(user: @free_user)
  end

  # Test user_can_collaborate_in_universe_that_allows_collective_content?
  test "user_can_collaborate_in_universe_that_allows_collective_content returns false when no premium collaborations" do
    refute PermissionService.user_can_collaborate_in_universe_that_allows_collective_content?(user: @free_user)
  end

  # Test user_has_active_promotion_for_this_content_type
  test "user_has_active_promotion_for_this_content_type returns false without promotion" do
    refute PermissionService.user_has_active_promotion_for_this_content_type(user: @free_user, content_type: 'Creature')
  end

  # Integration tests
  test "premium user permissions work correctly" do
    assert PermissionService.user_is_on_premium_plan?(user: @premium_user)
    assert PermissionService.billing_plan_allows_core_content?(user: @premium_user)
    assert PermissionService.billing_plan_allows_extended_content?(user: @premium_user)
    assert PermissionService.billing_plan_allows_collective_content?(user: @premium_user)
  end

  test "free user permissions work correctly" do
    refute PermissionService.user_is_on_premium_plan?(user: @free_user)
    assert PermissionService.billing_plan_allows_core_content?(user: @free_user)
    refute PermissionService.billing_plan_allows_extended_content?(user: @free_user)
    refute PermissionService.billing_plan_allows_collective_content?(user: @free_user)
  end

  test "content ownership works correctly" do
    # Free user owns their own content
    assert PermissionService.user_owns_content?(user: @free_user, content: @test_character)
    
    # Free user doesn't own premium user's content
    refute PermissionService.user_owns_content?(user: @free_user, content: @other_character)
    
    # Premium user owns their own content
    assert PermissionService.user_owns_content?(user: @premium_user, content: @other_character)
    
    # Premium user doesn't own free user's content
    refute PermissionService.user_owns_content?(user: @premium_user, content: @test_character)
  end

  test "content privacy detection works correctly" do
    # Set up public content
    @test_character.update(privacy: 'public')
    assert PermissionService.content_is_public?(content: @test_character)
    
    # Set up private content
    @other_character.update(privacy: 'private')
    refute PermissionService.content_is_public?(content: @other_character)
  end

  test "different billing plan types work correctly" do
    # Test beta user (plan ID 2)
    beta_user = User.create!(
      email: 'beta@example.com',
      password: 'password123',
      selected_billing_plan_id: 2
    )
    
    assert PermissionService.user_is_on_premium_plan?(user: beta_user)
    assert PermissionService.billing_plan_allows_extended_content?(user: beta_user)
    assert PermissionService.billing_plan_allows_collective_content?(user: beta_user)
  end

  private

  def stub_const(const_name, const_value)
    # Simple constant stubbing for testing
    Object.const_set(const_name, const_value) unless Object.const_defined?(const_name)
  end
end