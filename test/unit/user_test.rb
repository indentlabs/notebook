require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "user exists" do
    assert_not_nil build(:user), "Users factory is returning nil"
  end
end
