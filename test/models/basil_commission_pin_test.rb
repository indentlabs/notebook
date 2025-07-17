require 'test_helper'

class BasilCommissionPinTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @character = characters(:one)
  end

  test "should allow setting pinned to true" do
    commission = BasilCommission.new(
      user: @user,
      entity: @character,
      entity_type: 'Character',
      prompt: 'Test prompt',
      job_id: 'test_job_123',
      pinned: true
    )
    
    assert commission.valid?, "Commission with pinned=true should be valid"
    assert commission.pinned, "Commission should be pinned"
  end

  test "should allow setting pinned to false" do
    commission = BasilCommission.new(
      user: @user,
      entity: @character,
      entity_type: 'Character',
      prompt: 'Test prompt',
      job_id: 'test_job_456',
      pinned: false
    )
    
    assert commission.valid?, "Commission with pinned=false should be valid"
    assert_not commission.pinned, "Commission should not be pinned"
  end

  test "should default pinned to false if not specified" do
    commission = BasilCommission.new(
      user: @user,
      entity: @character,
      entity_type: 'Character',
      prompt: 'Test prompt',
      job_id: 'test_job_789'
    )
    
    assert_not commission.pinned, "Commission should default to not pinned"
  end

  test "pinned scope should return only pinned commissions" do
    pinned_commission = BasilCommission.create!(
      user: @user,
      entity: @character,
      entity_type: 'Character',
      prompt: 'Pinned test',
      job_id: 'pinned_job_123',
      pinned: true
    )
    
    unpinned_commission = BasilCommission.create!(
      user: @user,
      entity: @character,
      entity_type: 'Character',
      prompt: 'Unpinned test',
      job_id: 'unpinned_job_456',
      pinned: false
    )
    
    pinned_commissions = BasilCommission.pinned
    
    assert_includes pinned_commissions, pinned_commission
    assert_not_includes pinned_commissions, unpinned_commission
  end

  test "should update pinned status without triggering callbacks" do
    commission = BasilCommission.create!(
      user: @user,
      entity: @character,
      entity_type: 'Character',
      prompt: 'Test prompt',
      job_id: 'test_job_update',
      pinned: false
    )
    
    # This simulates what the controller does
    commission.update_column(:pinned, true)
    
    assert commission.reload.pinned, "Commission should be pinned after update_column"
  end

  test "multiple commissions can exist for same entity with different pin status" do
    commission1 = BasilCommission.create!(
      user: @user,
      entity: @character,
      entity_type: 'Character',
      prompt: 'First commission',
      job_id: 'job_1',
      pinned: true
    )
    
    commission2 = BasilCommission.create!(
      user: @user,
      entity: @character,
      entity_type: 'Character',
      prompt: 'Second commission',
      job_id: 'job_2',
      pinned: false
    )
    
    assert commission1.valid?
    assert commission2.valid?
    assert commission1.pinned
    assert_not commission2.pinned
  end

  test "should be able to query pinned commissions for specific entity" do
    # Create commissions for character 1
    char1_pinned = BasilCommission.create!(
      user: @user,
      entity: @character,
      entity_type: 'Character',
      prompt: 'Character 1 pinned',
      job_id: 'char1_pinned_job',
      pinned: true
    )
    
    char1_unpinned = BasilCommission.create!(
      user: @user,
      entity: @character,
      entity_type: 'Character',
      prompt: 'Character 1 unpinned',
      job_id: 'char1_unpinned_job',
      pinned: false
    )
    
    # Create commission for character 2
    char2 = characters(:two)
    char2_pinned = BasilCommission.create!(
      user: users(:two),
      entity: char2,
      entity_type: 'Character',
      prompt: 'Character 2 pinned',
      job_id: 'char2_pinned_job',
      pinned: true
    )
    
    # Query pinned commissions for character 1 only
    char1_pinned_commissions = BasilCommission.where(
      entity_type: 'Character',
      entity_id: @character.id,
      pinned: true
    )
    
    assert_equal 1, char1_pinned_commissions.count
    assert_includes char1_pinned_commissions, char1_pinned
    assert_not_includes char1_pinned_commissions, char1_unpinned
    assert_not_includes char1_pinned_commissions, char2_pinned
  end

  test "ordered scope should work with pinned commissions" do
    # Create commissions with different positions
    commission1 = BasilCommission.create!(
      user: @user,
      entity: @character,
      entity_type: 'Character',
      prompt: 'First commission',
      job_id: 'job_1',
      pinned: true,
      position: 2
    )
    
    commission2 = BasilCommission.create!(
      user: @user,
      entity: @character,
      entity_type: 'Character',
      prompt: 'Second commission', 
      job_id: 'job_2',
      pinned: false,
      position: 1
    )
    
    ordered_commissions = BasilCommission.where(entity: @character).ordered
    
    assert_equal commission2, ordered_commissions.first, "Commission with position 1 should be first"
    assert_equal commission1, ordered_commissions.second, "Commission with position 2 should be second"
  end

  test "should handle acts_as_paranoid for pinned commissions" do
    commission = BasilCommission.create!(
      user: @user,
      entity: @character,
      entity_type: 'Character',
      prompt: 'Test deletion',
      job_id: 'deletion_test_job',
      pinned: true
    )
    
    # Soft delete the commission
    commission.destroy
    
    # Should not appear in normal queries
    assert_not_includes BasilCommission.pinned, commission
    
    # Should appear in with_deleted queries
    assert_includes BasilCommission.with_deleted.pinned, commission
  end
end