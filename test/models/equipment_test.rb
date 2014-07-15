require 'test_helper'

class EquipmentTest < ActiveSupport::TestCase
  test "equipment exists" do
    assert_not_nil equipment(:one)
  end
  
  test "equipement belongs to user and universe" do
    assert_equal users(:one), equipment(:one).user
    assert_equal universes(:one), equipment(:one).universe
  end
end
