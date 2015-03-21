require 'test_helper'

class MagicTest < ActiveSupport::TestCase
  test "magic not valid without a name" do
    skip "Validation has been disabled due to conflicts during the database migration. We are considering removing this validation entirely"
    magic = magics(:wizard)
    magic.name = nil
    
    refute magic.valid?, "Magic name is not being validated for presence"
  end
  
  test "magic fixture assumptions" do
    assert_not_nil magics(:wizard), "Magics fixture :one is unavailable"
    assert magics(:wizard).valid?, "Magics fixture :one is not valid"
  end
end
