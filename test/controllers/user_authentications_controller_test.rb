require 'test_helper'

class UserAuthenticationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "requires login" do
    delete user_authentication_path(user_authentications(:user_one_google))
    assert_redirected_to new_user_session_path
  end

  test "a user can disconnect a linked provider when they know their password" do
    user = users(:one)
    authentication = user_authentications(:user_one_google)
    sign_in user

    assert_difference 'UserAuthentication.count', -1 do
      delete user_authentication_path(authentication)
    end

    assert_redirected_to user_more_actions_path(user)
  end

  test "an oauth-only user cannot disconnect their last linked provider" do
    user = users(:one)
    user.update_column(:password_automatically_set, true)
    authentication = user_authentications(:user_one_google)
    sign_in user

    assert_no_difference 'UserAuthentication.count' do
      delete user_authentication_path(authentication)
    end

    assert flash[:alert].present?
  end

  test "an oauth-only user can disconnect one of several linked providers" do
    user = users(:one)
    user.update_column(:password_automatically_set, true)
    second = user.user_authentications.create!(provider: 'discord', uid: 'second-uid')
    sign_in user

    assert_difference 'UserAuthentication.count', -1 do
      delete user_authentication_path(second)
    end
  end

  test "a user cannot disconnect another user's authentication" do
    sign_in users(:two)
    authentication = user_authentications(:user_one_google)

    assert_no_difference 'UserAuthentication.count' do
      delete user_authentication_path(authentication)
    end

    assert flash[:alert].present?
  end
end
