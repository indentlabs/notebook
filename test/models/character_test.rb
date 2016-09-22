require 'test_helper'

# Tests for the model class Character
class CharacterTest < ActiveSupport::TestCase
  test 'character not valid without a name' do
    character = build(:character, name: nil)

    refute character.valid?, 'Character name not being validated for presence'
  end

  test 'character is public when privacy field contains "public"' do
    universe = build(:universe, privacy: 'private')
    character = build(:character, privacy: 'public', universe: universe)

    assert character.public_content?
    refute character.private_content?
  end

  test 'character is private when privacy field contains "private"' do
    universe = build(:universe, privacy: 'private')
    character = build(:character, privacy: 'private', universe: universe)

    assert character.private_content?
    refute character.public_content?
  end

  test 'character is private when privacy field is empty' do
    character = build(:character, privacy: '')

    assert character.private_content?
    refute character.public_content?
  end

  test 'character is public when universe is public' do
    universe = build(:universe, privacy: 'public')
    character = build(:character, privacy: 'private', universe: universe)

    assert character.public_content?
    refute character.private_content?
  end
end
