require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "user not valid without a name" do
    user = users(:one)
    user.name = nil
    
    refute user.valid?, "Name is not being validated for presence"
  end
  
  test "user not valid without a password" do
    user = users(:one)
    user.password = nil
    
    refute user.valid?, "Password is not being validated for presence"
  end
  
  test "user not valid without an email address" do
    user = users(:one)
    user.email = nil
    
    refute user.valid?, "Email address is not being validated for presence"
  end
  
  test "user fixture assumptions" do
    assert_not_nil users(:one), "User fixture :one is unavailable"
    assert users(:one).valid?, "User fixture :one is not a valid user"
  end
  
  test "can get user content" do
    content = users(:one).content
    
    assert_includes content[:characters], characters(:one), "User content doesn't include characters"
    assert_includes content[:equipment], equipment(:one), "User content doesn't include equipment"
    assert_includes content[:languages], languages(:one), "User content doesn't include languages"
    assert_includes content[:locations], locations(:one), "User content doesn't include locations"
    assert_includes content[:magics], magics(:one), "User content doesn't include magics"
    assert_includes content[:universes], universes(:one), "User content doesn't include universes"
  end
  
  test "can count content" do
    assert_equal 6, users(:one).content_count, "User didn't count its content properly"
  end
end
