require "test_helper"

class StyleguideControllerTest < ActionDispatch::IntegrationTest
  test "should get tailwind" do
    get styleguide_tailwind_url
    assert_response :success
  end
end
