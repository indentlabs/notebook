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

  test 'character is_public scope' do
    public_universe = create(:universe, privacy: 'public')
    private_universe = create(:universe, privacy: 'private')

    pub_character_pub_universe = create(:character, privacy: 'public', universe: public_universe)
    pub_character_priv_universe = create(:character, privacy: 'public', universe: private_universe)
    priv_character_pub_universe = create(:character, privacy: 'private', universe: public_universe)
    priv_character_priv_universe = create(:character, privacy: 'private', universe: private_universe)

    public_scope = Character.is_public

    assert_includes public_scope, pub_character_pub_universe, "didn't contain a public character in a public universe"
    assert_includes public_scope, pub_character_priv_universe, "didn't contain a public character in a private universe"
    assert_includes public_scope, priv_character_pub_universe, "didn't contain a private character in a public universe"

    refute_includes public_scope, priv_character_priv_universe, "contained a private character in a private universe"
  end
end
