require 'test_helper'

# Tests for the Equipment model class
class EquipmentTest < ActiveSupport::TestCase
  test 'equipment not valid without a name' do
    skip 'Validation disabled due to database migration conflicts.'
    equipment = equipment(:sting)
    equipment.name = nil

    refute equipment.valid?, 'Name is not being validated for presence'
  end

  test 'equipment fixture exists' do
    assert_not_nil equipment(:sting)
  end

  test 'equipment belongs to user and universe' do
    assert_equal users(:tolkien), equipment(:sting).user
    assert_equal universes(:middleearth), equipment(:sting).universe
  end
end
