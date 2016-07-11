require 'test_helper'

# Tests for the model class Character
class CharacterTest < ActiveSupport::TestCase
  test 'character not valid without a name' do
    character = build(:character, name: nil)

    refute character.valid?, 'Character name not being validated for presence'
  end
end
