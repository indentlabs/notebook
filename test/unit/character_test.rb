require 'test_helper'

class CharacterTest < ActiveSupport::TestCase
  test "character exists" do
    assert_not_nil build(:character), "Characters factory is returning nil"
  end
end
