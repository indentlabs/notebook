require 'test_helper'
require 'has_privacy_test'

# Tests for the model class Character
class CharacterTest < ActiveSupport::TestCase
  include HasPrivacyTest

  setup do
    @character = build(:character)

    # for HasPrivacyTest
    @object = @character
  end

  test 'character not valid without a name' do
    @character.name = nil

    refute @character.valid?, 'Character name not being validated for presence'
  end
end
