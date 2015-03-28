require 'test_helper'

# Tests for the Location model class
class LocationTest < ActiveSupport::TestCase
  test 'location not valid without a name' do
    location = locations(:shire)
    location.name = nil

    refute location.valid?, 'Location name is not being validated for presence'
  end

  test 'location fixture assumptions' do
    assert_not_nil locations(:shire),
                   'Locations fixture not available'

    assert locations(:shire).valid?,
           'Locations fixture not valid'

    assert_equal users(:tolkien), locations(:shire).user,
                 'Locations fixture associated with Users fixture'

    assert_equal universes(:middleearth), locations(:shire).universe,
                 'Locations fixture not associated with Universes fixture'
  end
end
