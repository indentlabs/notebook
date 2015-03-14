require 'test_helper'

class UniverseTest < ActiveSupport::TestCase
  test "universe exists" do
    assert_not_nil universes(:one)
  end
end
