require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  test "location exists" do
      assert_not_nil locations(:one)
  end
end
