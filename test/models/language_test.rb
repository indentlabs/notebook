require 'test_helper'

class LanguageTest < ActiveSupport::TestCase
  test "language exists" do
    assert_not_nil languages(:one)
  end
  
  test "language belongs to user and universe" do
    assert_equal users(:one), languages(:one).user
    assert_equal universes(:one), languages(:one).universe
  end
end
