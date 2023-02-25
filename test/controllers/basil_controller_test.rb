require "test_helper"

class BasilControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get basil_index_url
    assert_response :success
  end
end
