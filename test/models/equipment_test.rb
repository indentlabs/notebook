require 'test_helper'

class EquipmentTest < ActiveSupport::TestCase
  test "equipment not valid without a name" do
    equipment = equipment(:one)
    equipment.name = nil
    
    refute equipment.valid?, "Name is not being validated for presence"
  end
  
  test "equipment fixture exists" do
    assert_not_nil equipment(:one)
  end
  
  test "equipement belongs to user and universe" do
    assert_equal users(:one), equipment(:one).user
    assert_equal universes(:one), equipment(:one).universe
  end
end
