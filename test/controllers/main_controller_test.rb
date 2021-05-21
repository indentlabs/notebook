require 'test_helper'

class MainControllerTest < ActionDispatch::IntegrationTest
  test "should get root path" do
    get root_url
    assert_response :success
  end

  

end
