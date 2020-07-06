require 'test_helper'

class StreamControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get stream_index_url
    assert_response :success
  end

end
