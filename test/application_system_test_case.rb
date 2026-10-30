require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  include Devise::Test::IntegrationHelpers

  # Optional: Use headless Chrome for CI, regular Chrome for development
  # driven_by :selenium, using: ENV['CI'] ? :headless_chrome : :chrome, screen_size: [1400, 1400]

  # For debugging: Take screenshots on failures
  def after_teardown
    super
    if failures.any?
      take_screenshot
    end
  end
end