require 'test_helper'

# Tests for the model class Character
class CharacterTest < ActiveSupport::TestCase
  test 'character not valid without a name' do
    character = build(:character, name: nil)

    refute character.valid?, 'Character name not being validated for presence'
  end

  test 'public character' do
    character = build(:character, privacy: 'public')

    assert character.public?
    refute character.private?
  end

  test 'private character -- field contains "private"' do
    character = build(:character, privacy: 'private')

    assert character.private?
    refute character.public?
  end

  test 'private character -- field is empty' do
    character = build(:character, privacy: '')

    assert character.private?
    refute character.public?
  end
end
