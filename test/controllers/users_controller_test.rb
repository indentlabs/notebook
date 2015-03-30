require 'test_helper'

# Tests for the UsersController class
class UsersControllerTest < ActionController::TestCase
  test 'editing a user requires login' do
    get :edit, id: users(:tolkien).id
    assert_redirected_to signup_path
  end

  test 'updating a user requires login' do
    @user = users(:tolkien)
    put :update, id: @user, user: { password: 'Hacked!' }
    assert_redirected_to signup_path
  end

  test 'logged-in user can edit self' do
    log_in_user :tolkien
    get :edit, id: users(:tolkien).id
    assert_response :success
  end

  test 'create user' do
    assert_difference('User.count') do
      post :create, user: {
        name: 'ChrisTolkien',
        password: 'HiDad',
        email: 'tolkienjr@example.com'
      }
    end
    assert_redirected_to homepage_path
  end

  test 'can create an anonymous account' do
    get :anonymous_login
    assert_redirected_to dashboard_path
  end
end
