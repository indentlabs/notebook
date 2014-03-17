require 'test_helper'

class SessionTest < ActiveSupport::TestCase
  test "session exists" do
    assert_not_nil build(:session), "Sessions factory is returning nil"
  end
end
