require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  test 'location not valid without a name' do
    location = locations(:shire)
    location.name = nil

    refute location.valid?, 'Location name is not being validated for presence'
  end

  test 'location fixture assumptions' do
    assert_not_nil locations(:shire), 'Locations fixture :one not available'
    assert locations(:shire).valid?, 'Locations fixture :one not valid'

    assert_equal users(:tolkien), locations(:shire).user, 'Locations fixture :one not associated with Users fixture :one'
    assert_equal universes(:middleearth), locations(:shire).universe, 'Locations fixture :one not associated with Universes fixture :one'
  end
end
