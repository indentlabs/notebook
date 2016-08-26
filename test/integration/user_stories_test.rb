require 'test_helper'

# Tests scenarios related to users and their accounts
class UserStoriesTest < ActionDispatch::IntegrationTest
  test 'clicking sign up goes to the sign up page' do
    visit root_url
    click_on 'Sign up'

    assert_equal new_user_registration_path, current_path
  end

  test 'submitting the user registration form dumps the user on their dashboard' do
    user = build(:user)
    register_as user.email, user.password

    assert_equal dashboard_path, current_path
  end

  test 'logging in as an existing user goes to the users dashboard' do
    user = create(:user)
    log_in_as user.email, user.password

    assert_equal dashboard_path, current_path,
                 'Existing user was not directed to their dashboard \
                  after logging in'
  end

  test 'user can register, log out, and log back in' do
    user = build(:user)
    register_as user.email, user.password
    log_out
    log_in_as user.email, user.password
    assert_equal dashboard_path, current_path
  end
end
