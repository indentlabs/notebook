require 'test_helper'

class NotificationControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get notification_index_url
    assert_response :success
  end

  test "should get show" do
    get notification_show_url
    assert_response :success
  end

end
