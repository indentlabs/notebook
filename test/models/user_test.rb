require 'test_helper'

# Tests for the User model class
class UserTest < ActiveSupport::TestCase
  test 'user has a Gravatar profile image' do
    user = build(:user, email: 'profile.image.test@example.com')

    assert_match 'https://www.gravatar.com/avatar/d2fd00e79c471f49c33b6bcb6b08d08d', user.image_url
  end
end
