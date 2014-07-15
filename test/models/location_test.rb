require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  test "location exists" do
      assert_not_nil locations(:one)
  end
  
  test "location belongs to user and universe" do
    assert_equal users(:one), locations(:one).user
    assert_equal universes(:one), locations(:one).universe
  end
end
