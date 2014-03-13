require 'test_helper'

class SessionTest < ActiveSupport::TestCase
  test "session exists" do
    assert_not_nil sessions(:one), "Sessions test fixture is inaccessible"
    assert_not_nil sessions(:two), "Sessions test fixture is inaccessible"
  end
end
