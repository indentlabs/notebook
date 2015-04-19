require 'test_helper'
require 'rails/performance_test_help'

# Tests performance by browsing the site
# Refer to the documentation for all available options
# self.profile_options = { :runs => 5, :metrics => [:wall_time, :memory]
#                          :output => 'tmp/performance', :formats => [:flat] }
class BrowsingTest < ActionDispatch::PerformanceTest
  def test_homepage
    get '/'
  end
end
