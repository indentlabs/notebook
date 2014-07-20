require 'test_helper'

class UniverseTest < ActiveSupport::TestCase
  test "universe not valid without a name" do
    universe = universes(:one)
    universe.name = nil
    
    refute universe.valid?, "Universe name is not being validated for presence"
  end
  
  test "universe fixture assumptions" do
    assert_not_nil universes(:one), "Universes fixture :one is not available"
    assert universes(:one).valid?, "Universes fixture :one is not a valid universe"
    assert_equal users(:one), universes(:one).user, "Universe fixture :one not associated with User fixture :one"
  end
  
  test "can count content" do
    assert_equal 5, universes(:one).content_count, "Universe didn't count its content properly"
  end
end
