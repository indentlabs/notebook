require 'test_helper'

class EquipmentTest < ActiveSupport::TestCase
  test "equipement exists" do
    assert_not_nil equipment(:one)
  end
end
