require 'test_helper'

class CharacterTest < ActiveSupport::TestCase
  test "character not valid without a name" do
    skip "Validation has been disabled due to conflicts during the database migration. We are considering removing this validation"
    character = characters(:frodo)
    character.name = nil
    
    refute character.valid?, "Character name not being validated for presence"
  end
  
  test "characters fixture assumptions" do
    assert_not_nil characters(:frodo), "Characters fixture :one is not available"
    assert characters(:frodo).valid?, "Characters fixture :one is not valid"
    
    assert_equal users(:tolkien), characters(:frodo).user, "Characters fixture :one is not associated with Users fixture :one"
    assert_equal universes(:middleearth), characters(:frodo).universe, "Characters fixture :one is not associated with Universes fixture :one"
  end
end
