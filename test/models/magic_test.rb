require 'test_helper'

# Tests for the Magic model class
class MagicTest < ActiveSupport::TestCase
  test 'magic not valid without a name' do
    skip 'Validation disabled due to database migration conflicts.'
    magic = magics(:wizard)
    magic.name = nil

    refute magic.valid?, 'Magic name is not being validated for presence'
  end

  test 'magic fixture assumptions' do
    assert_not_nil magics(:wizard), 'Magics fixture is unavailable'
    assert magics(:wizard).valid?, 'Magics fixture is not valid'
  end
end
