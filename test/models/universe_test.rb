require 'test_helper'

class UniverseTest < ActiveSupport::TestCase
  test 'universe not valid without a name' do
    skip 'Validation has been disabled due to conflicts during the database migration. We are considering removing this validation entirely'
    universe = universes(:middleearth)
    universe.name = nil

    refute universe.valid?, 'Universe name is not being validated for presence'
  end

  test 'universe fixture assumptions' do
    assert_not_nil universes(:middleearth), 'Universes fixture :one is not available'
    assert universes(:middleearth).valid?, 'Universes fixture :one is not a valid universe'
    assert_equal users(:tolkien), universes(:middleearth).user, 'Universe fixture :one not associated with User fixture :one'
  end

  test 'can count content' do
    assert_equal 5, universes(:middleearth).content_count, "Universe didn't count its content properly"
  end
end
