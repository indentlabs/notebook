require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should get user profile without error" do
    test_user = User.create(email: 'test+test@test.test', password: 'testtesttest')

    get :show, id: test_user.id
    assert_response :success
  end

end
