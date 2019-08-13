require 'test_helper'

class NoticeDismissalControllerTest < ActionDispatch::IntegrationTest
  test "should get dismiss" do
    get notice_dismissal_dismiss_url
    assert_response :success
  end

end
