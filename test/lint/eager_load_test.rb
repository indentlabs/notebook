require 'test_helper'

# Production loads every file in app/ when it boots. Tests normally load only
# the files they touch, so a file with a syntax error or a reference to a
# constant that no longer exists can pass the whole suite and then take the
# site down. Loading everything here catches that.
class EagerLoadTest < ActiveSupport::TestCase
  test "every file in the app loads" do
    assert_nothing_raised { Rails.application.eager_load! }
  end
end
