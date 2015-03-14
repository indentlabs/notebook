require 'test_helper'

class SessionTest < ActiveSupport::TestCase
  test "session exists" do
    assert_not_nil sessions(:one)
  end
end
