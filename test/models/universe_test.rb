require 'test_helper'

# Tests for the Universe model class
class UniverseTest < ActiveSupport::TestCase
  test 'universe not valid without a name' do
    universe = universes(:middleearth)
    universe.name = nil

    refute universe.valid?, 'Universe name is not being validated for presence'
  end

  test 'universe fixture assumptions' do
    assert_not_nil universes(:middleearth),
                   'Universes fixture is not available'

    assert universes(:middleearth).valid?,
           'Universes fixture is not a valid universe'

    assert_equal users(:tolkien), universes(:middleearth).user,
                 'Universe fixture not associated with User fixture'
  end

  test 'can count content' do
    assert_equal 2, universes(:middleearth).content_count,
                 "Universe didn't count its content properly"
  end
end
