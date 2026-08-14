require 'test_helper'

class OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    OmniAuth.config.test_mode = true
  end

  teardown do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.mock_auth[:discord] = nil
    OmniAuth.config.test_mode = false
  end

  def mock_oauth(provider: :google_oauth2, uid: 'mock-uid', email: 'mock.user@example.com', name: 'Mock User')
    OmniAuth.config.mock_auth[provider] = OmniAuth::AuthHash.new(
      provider: provider.to_s,
      uid: uid,
      info: { email: email, name: name }
    )
  end

  def complete_oauth_flow(provider: :google_oauth2)
    post "/users/auth/#{provider}"
    follow_redirect!
  end

  def assert_signed_in(user)
    assert_equal [user.id], session['warden.user.user.key']&.first,
      "Expected #{user.email} to be signed in"
  end

  test "signs in a user whose authentication is already linked" do
    authentication = user_authentications(:user_one_google)
    mock_oauth(uid: authentication.uid, email: 'anything@example.com')

    complete_oauth_flow
    assert_redirected_to root_path
    assert_signed_in authentication.user
  end

  test "signs in an existing user by verified email and links the authentication" do
    user = users(:two)
    mock_oauth(uid: 'fresh-google-uid', email: user.email)

    assert_no_difference 'User.count' do
      complete_oauth_flow
    end

    assert_redirected_to root_path
    assert_signed_in user
    assert user.user_authentications.exists?(provider: 'google_oauth2', uid: 'fresh-google-uid')
  end

  test "creates and signs in a brand-new user" do
    mock_oauth(uid: 'new-user-uid', email: 'brand.new@example.com', name: 'Brand New')

    assert_difference 'User.count', 1 do
      complete_oauth_flow
    end

    assert_redirected_to root_path

    new_user = User.find_by(email: 'brand.new@example.com')
    assert new_user.present?
    assert_signed_in new_user
    assert new_user.password_automatically_set?
    assert new_user.user_authentications.exists?(provider: 'google_oauth2', uid: 'new-user-uid')
  end

  test "new OAuth signups get pending contributor invites linked" do
    universe_owner = users(:one)
    universe = Universe.create!(name: 'Shared World', user: universe_owner)
    Contributor.create!(universe: universe, email: 'invited.writer@example.com', user: nil)

    mock_oauth(uid: 'invited-uid', email: 'invited.writer@example.com')
    complete_oauth_flow

    new_user = User.find_by(email: 'invited.writer@example.com')
    assert new_user.present?
    assert_equal new_user.id, Contributor.find_by(universe: universe).user_id
    assert new_user.notifications.exists?(reference_code: 'contributor-added')
  end

  test "works for discord as well" do
    mock_oauth(provider: :discord, uid: 'discord-uid', email: 'discord.user@example.com')

    assert_difference 'User.count', 1 do
      complete_oauth_flow(provider: :discord)
    end

    new_user = User.find_by(email: 'discord.user@example.com')
    assert new_user.user_authentications.exists?(provider: 'discord', uid: 'discord-uid')
  end

  test "redirects to signup when the provider sends no email" do
    mock_oauth(uid: 'no-email-uid', email: nil)

    assert_no_difference 'User.count' do
      complete_oauth_flow
    end

    assert_redirected_to new_user_registration_url
    assert flash[:alert].present?
  end

  test "a signed-in user linking a new provider gets it attached to their account" do
    user = users(:two)
    sign_in user
    mock_oauth(provider: :discord, uid: 'link-me-uid', email: user.email)

    assert_no_difference 'User.count' do
      complete_oauth_flow(provider: :discord)
    end

    assert_redirected_to user_more_actions_path(user)
    assert user.user_authentications.exists?(provider: 'discord', uid: 'link-me-uid')
  end

  test "a signed-in user cannot link a provider account already linked elsewhere" do
    authentication = user_authentications(:user_one_google)
    user = users(:two)
    sign_in user
    mock_oauth(uid: authentication.uid, email: user.email)

    complete_oauth_flow

    assert_redirected_to user_more_actions_path(user)
    assert_not user.user_authentications.exists?(provider: 'google_oauth2')
    assert_equal users(:one).id, authentication.reload.user_id
    assert flash[:alert].present?
  end
end
