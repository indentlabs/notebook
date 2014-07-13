require 'test_helper'

class CharacterTest < ActiveSupport::TestCase
  test "character exists" do
    assert_not_nil characters(:one)
  end
  
  test "get columns" do
    assert_equal "Test", characters(:one).name
  end
end
