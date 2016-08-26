require 'test_helper'

class WriteControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user)

    sign_in @user
  end

  test "should get editor" do
    get :editor, scene_id: 1
    assert_response :success
  end

end
