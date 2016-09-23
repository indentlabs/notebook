require 'test_helper'

# Tests for the Universe model class
class UniverseTest < ActiveSupport::TestCase
  test 'universe not valid without a name' do
    universe = build(:universe, name: nil)

    refute universe.valid?, 'Universe name is not being validated for presence'
  end

  test 'universe is private when privacy field contains "private"' do
    universe = build(:universe, privacy: 'private')

    assert universe.private_content?
    refute universe.public_content?
  end

  test 'universe is private when privacy field is empty' do
    universe = build(:universe, privacy: '')

    assert universe.private_content?
    refute universe.public_content?
  end
end
