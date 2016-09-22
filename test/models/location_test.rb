require 'test_helper'
require 'has_privacy_test'

# Tests for the Location model class
class LocationTest < ActiveSupport::TestCase
  include HasPrivacyTest

  setup do
    @location = create(:location)
    @object = @location
  end

  test 'location not valid without a name' do
    @location.name = nil

    refute @location.valid?, 'Location name is not being validated for presence'
  end
end
