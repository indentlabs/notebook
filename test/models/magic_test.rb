require 'test_helper'

class MagicTest < ActiveSupport::TestCase
  test "magic exists" do
    assert_not_nil magics(:one)
  end
  
  test "magic belongs to user and universe" do
    assert_equal users(:one), magics(:one).user
    assert_equal universes(:one), magics(:one).universe
  end
end
