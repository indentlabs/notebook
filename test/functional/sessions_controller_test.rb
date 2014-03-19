require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  setup do
    @session = build(:session)
  end
  
  teardown do
    DatabaseCleaner.clean
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create session" do
    assert_difference('Session.count') do
      post :create, session: { password: @session.password, username: @session.username }
    end

    assert_redirected_to session_path(assigns(:session))
  end

  test "should destroy session" do
    @session.save
    assert_difference('Session.count', -1) do
      delete :destroy, id: @session
    end

    assert_redirected_to sessions_path
  end
end
