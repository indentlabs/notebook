require 'test_helper'

class MagicTest < ActiveSupport::TestCase
  test "magic exists" do
    assert_not_nil magics(:one)
  end
end
