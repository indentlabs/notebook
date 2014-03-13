require 'test_helper'

class CharacterTest < ActiveSupport::TestCase
  test "character exists" do
    assert_not_nil characters(:one), "Characters test fixture is inaccessible"
    assert_not_nil characters(:two), "Characters test fixture is inaccessible"
  end
end
