require 'test_helper'

# Tests for the Location model class
class LocationTest < ActiveSupport::TestCase
  test 'location not valid without a name' do
    location = build(:location, name: nil)

    refute location.valid?, 'Location name is not being validated for presence'
  end
end
