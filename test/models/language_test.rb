require 'test_helper'

class LanguageTest < ActiveSupport::TestCase
  test "language exists" do
    assert_not_nil languages(:one)
  end
end
