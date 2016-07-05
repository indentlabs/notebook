require 'test_helper'

# Tests scenarios related to users and their accounts
class UserStoriesTest < ActionDispatch::IntegrationTest
  test 'creating a new user ends at the new user\'s dashboard' do
    register_as 'tolkienjr@example.com', 'HiDad'
    assert_equal dashboard_path, current_path,
                 'New user was not directed to their dashboard \
                  after creating an account'
  end

  test 'logging in as an existing user goes to the users dashboard' do
    log_in_as_user

    assert_equal dashboard_path, current_path,
                 'Existing user was not directed to their dashboard \
                  after logging in'
  end

  ##
  # Regression test for https://github.com/drusepth/Indent/issues/378
  test 'user can log in to new accounts' do
    register_as 'tolkienjr@example.com', 'HiDad'
    log_out
    log_in_as 'tolkienjr@example.com', 'HiDad'
    assert_equal dashboard_path, current_path,
                 'Users cannot log in to new accounts, \
                  regression of https://github.com/drusepth/Indent/issues/378'
  end
end
