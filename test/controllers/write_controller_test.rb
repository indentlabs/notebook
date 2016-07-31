require 'test_helper'

class WriteControllerTest < ActionController::TestCase
  test "should get editor" do
    get :editor
    assert_response :success
  end

end
