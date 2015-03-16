require 'test_helper'

class CharacterTest < ActiveSupport::TestCase
  test "character not valid without a name" do
    character = characters(:one)
    character.name = nil
    
    refute character.valid?, "Character name not being validated for presence"
  end
  
  test "characters fixture assumptions" do
    assert_not_nil characters(:one), "Characters fixture :one is not available"
    assert characters(:one).valid?, "Characters fixture :one is not valid"
    
    assert_equal users(:one), characters(:one).user, "Characters fixture :one is not associated with Users fixture :one"
    assert_equal universes(:one), characters(:one).universe, "Characters fixture :one is not associated with Universes fixture :one"
  end
end
