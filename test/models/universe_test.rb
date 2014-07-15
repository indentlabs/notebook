require 'test_helper'

class UniverseTest < ActiveSupport::TestCase
  test "universe exists" do
    assert_not_nil universes(:one)
  end
  
  test "universe belongs to user" do
    assert_equal users(:one), universes(:one).user
  end
  
  test "associations associate" do
    assert_not_nil universes(:one).characters
    assert_not_nil universes(:one).equipment
    assert_not_nil universes(:one).languages
    assert_not_nil universes(:one).locations
    assert_not_nil universes(:one).magics
  end
  
  test "can count content" do
    assert_equal 5, universes(:one).content_count
  end
end
