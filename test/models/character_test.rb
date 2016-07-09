require 'test_helper'

# Tests for the model class Character
class CharacterTest < ActiveSupport::TestCase
  test 'character not valid without a name' do
    character = characters(:frodo)
    character.name = nil

    refute character.valid?, 'Character name not being validated for presence'
  end

  test 'characters fixture assumptions' do
    assert_not_nil characters(:frodo), 'Characters fixture is not available'
    assert characters(:frodo).valid?, 'Characters fixture is not valid'

    assert_equal(
      users(:tolkien),
      characters(:frodo).user,
      'Characters fixture is not associated with Users fixture')

    assert_equal(
      universes(:middleearth),
      characters(:frodo).universe,
      'Characters fixture is not associated with Universes fixture')
  end
end
