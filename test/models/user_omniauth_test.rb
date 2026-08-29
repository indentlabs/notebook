require 'test_helper'

class UserOmniauthTest < ActiveSupport::TestCase
  def auth_hash(provider: 'google_oauth2', uid: 'new-uid-123', email: 'oauth.user@example.com', name: 'OAuth User')
    OmniAuth::AuthHash.new(
      provider: provider,
      uid: uid,
      info: { email: email, name: name }
    )
  end

  test "returns the linked user when the authentication already exists" do
    authentication = user_authentications(:user_one_google)

    user = User.from_omniauth(auth_hash(uid: authentication.uid, email: 'different@example.com'))
    assert_equal authentication.user, user
  end

  test "links to an existing account by verified email" do
    existing = users(:two)

    user = User.from_omniauth(auth_hash(uid: 'brand-new-uid', email: existing.email))
    assert_equal existing, user
    assert existing.user_authentications.exists?(provider: 'google_oauth2', uid: 'brand-new-uid')
    assert_not user.password_automatically_set?
  end

  test "matches existing accounts case-insensitively by email" do
    existing = users(:two)

    user = User.from_omniauth(auth_hash(uid: 'case-uid', email: existing.email.upcase))
    assert_equal existing, user
  end

  test "creates a new account when no user matches" do
    assert_difference 'User.count', 1 do
      user = User.from_omniauth(auth_hash)
      assert user.persisted?
      assert_equal 'oauth.user@example.com', user.email
      assert_equal 'OAuth User', user.name
      assert user.password_automatically_set?
      assert user.oauth_only?
      assert user.user_authentications.exists?(provider: 'google_oauth2', uid: 'new-uid-123')
    end
  end

  test "returns an unpersisted user when the provider sends no email" do
    assert_no_difference 'User.count' do
      user = User.from_omniauth(auth_hash(email: nil))
      assert_not user.persisted?
      assert user.errors[:email].any?
    end
  end

  test "oauth_only? is false once the user changes their password" do
    user = User.from_omniauth(auth_hash(uid: 'pw-test-uid', email: 'pw.test@example.com'))
    assert user.oauth_only?

    user.update(password: 'a-real-password', password_confirmation: 'a-real-password')
    assert_not user.reload.password_automatically_set?
    assert_not user.oauth_only?
  end
end
