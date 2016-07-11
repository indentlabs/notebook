require 'test_helper'

# Tests for the Universe model class
class UniverseTest < ActiveSupport::TestCase
  test 'universe not valid without a name' do
    universe = build(:universe, name: nil)

    refute universe.valid?, 'Universe name is not being validated for presence'
  end
end
