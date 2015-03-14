require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "user exists" do
    assert_not_nil users(:one)
  end
end
