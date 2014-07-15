require 'test_helper'

class CharacterTest < ActiveSupport::TestCase
  test "character exists" do
    assert_not_nil characters(:one)
  end
  
  test "character belongs to user and universe" do
    assert_equal users(:one), characters(:one).user
    assert_equal universes(:one), characters(:one).universe
  end
end
