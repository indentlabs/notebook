require 'test_helper'

# Tests for the model class Character
class CharacterTest < ActiveSupport::TestCase
  test 'character not valid without a name' do
    character = build(:character, name: nil)

    refute character.valid?, 'Character name not being validated for presence'
  end

  test 'character is public when privacy field contains "public"' do
    character = build(:character, privacy: 'public')

    assert character.public?
    refute character.private?
  end

  test 'character is private when privacy field contains "private"' do
    character = build(:character, privacy: 'private')

    assert character.private?
    refute character.public?
  end

  test 'character is private when privacy field is empty' do
    character = build(:character, privacy: '')

    assert character.private?
    refute character.public?
  end
end
