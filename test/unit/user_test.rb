require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "user exists" do
    assert_not_nil user(:one), "Users test fixture is inaccessible"
    assert_not_nil user(:two), "Users test fixture is inaccessible"
  end
end
