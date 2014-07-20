require 'test_helper'

class LanguageTest < ActiveSupport::TestCase
  test "language not valid without a name" do
    language = languages(:one)
    language.name = nil
    
    refute language.valid?, "Language name not being validated for presence"
  end
  
  test "language fixture exists" do
    assert_not_nil languages(:one)
  end
  
  test "language belongs to user and universe" do
    assert_equal users(:one), languages(:one).user
    assert_equal universes(:one), languages(:one).universe
  end
end
