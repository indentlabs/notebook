require 'test_helper'

class UserAuthenticationTest < ActiveSupport::TestCase
  test "requires provider and uid" do
    authentication = UserAuthentication.new(user: users(:one))
    assert_not authentication.valid?
    assert authentication.errors[:provider].any?
    assert authentication.errors[:uid].any?
  end

  test "uid must be unique per provider" do
    existing = user_authentications(:user_one_google)

    duplicate = UserAuthentication.new(user: users(:two), provider: existing.provider, uid: existing.uid)
    assert_not duplicate.valid?

    same_uid_other_provider = UserAuthentication.new(user: users(:two), provider: 'discord', uid: existing.uid)
    assert same_uid_other_provider.valid?
  end
end
