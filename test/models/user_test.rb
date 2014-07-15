require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "user exists" do
    assert_not_nil users(:one)
  end
  
  test "can get user content" do
    content = users(:one).content
    
    assert_includes content[:characters], characters(:one)
    assert_includes content[:equipment], equipment(:one)
    assert_includes content[:languages], languages(:one)
    assert_includes content[:locations], locations(:one)
    assert_includes content[:magics], magics(:one)
    assert_includes content[:universes], universes(:one)
  end
  
  test "can count content" do
    assert_equal 6, users(:one).content_count
  end
end
