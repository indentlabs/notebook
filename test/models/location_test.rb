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

  test 'location is_public scope' do
    public_universe = create(:universe, privacy: 'public')
    private_universe = create(:universe, privacy: 'private')

    pub_location_pub_universe = create(:location, privacy: 'public', universe: public_universe)
    pub_location_priv_universe = create(:location, privacy: 'public', universe: private_universe)
    priv_location_pub_universe = create(:location, privacy: 'private', universe: public_universe)
    priv_location_priv_universe = create(:location, privacy: 'private', universe: private_universe)

    public_scope = Location.is_public

    assert_includes public_scope, pub_location_pub_universe, "didn't contain a public location in a public universe"
    assert_includes public_scope, pub_location_priv_universe, "didn't contain a public location in a private universe"
    assert_includes public_scope, priv_location_pub_universe, "didn't contain a private location in a public universe"

    refute_includes public_scope, priv_location_priv_universe, "contained a private location in a private universe"
  end
end
