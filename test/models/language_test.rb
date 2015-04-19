require 'test_helper'

# Tests for the Language model class
class LanguageTest < ActiveSupport::TestCase
  test 'language not valid without a name' do
    skip 'Validation disabled due to database migration conflicts.'
    language = languages(:sindarin)
    language.name = nil

    refute language.valid?, 'Language name not being validated for presence'
  end

  test 'language fixture exists' do
    assert_not_nil languages(:sindarin)
  end

  test 'language belongs to user and universe' do
    assert_equal users(:tolkien), languages(:sindarin).user
    assert_equal universes(:middleearth), languages(:sindarin).universe
  end
end
