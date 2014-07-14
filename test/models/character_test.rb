require 'test_helper'

class CharacterTest < ActiveSupport::TestCase
  test "character exists" do
    assert_not_nil characters(:one)
  end
  
  test "get columns" do
    assert_equal "Test", characters(:one).name
  end
  
  test "get associated tables" do
    assert_equal users(:one), characters(:one).user
    assert_equal universes(:one), characters(:one).universe
  end
end
