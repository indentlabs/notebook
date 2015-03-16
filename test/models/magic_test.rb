require 'test_helper'

class MagicTest < ActiveSupport::TestCase
  test "magic not valid without a name" do
    magic = magics(:one)
    magic.name = nil
    
    refute magic.valid?, "Magic name is not being validated for presence"
  end
  
  test "magic fixture assumptions" do
    assert_not_nil magics(:one), "Magics fixture :one is unavailable"
    assert magics(:one).valid?, "Magics fixture :one is not valid"
  end
end
