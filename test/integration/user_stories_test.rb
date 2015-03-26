require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
  test 'creating a new user ends at the new user\'s dashboard' do
    register_as 'Christopher Tolkien', 'tolkienjr@example.com', 'HiDad'
    assert_equal dashboard_path, current_path, 'New user was not directed to their dashboard after creating an account'
  end

  test 'logging in as an existing user goes to the users dashboard' do
    log_in_as_user

    assert_equal dashboard_path, current_path, 'Existing user was not directed to their dashboard after logging in'
  end

  test 'logging in anonymously goes into an empty dashboard' do
    log_in_as_anon

    assert_equal dashboard_path, current_path, 'Anonymous user was not directed to their dashboard after logging in'
  end

  # Regression test for https://github.com/drusepth/Indent/issues/366

  test 'Anonymous flag is reset on user logins' do
    log_in_as_anon
    log_out
    log_in_as_user
    refute page.has_content?('You are currently using an anonymous account'), 'Logged-in user was told they were using an anonymous account, regression of https://github.com/drusepth/Indent/issues/366'
  end

  # Regression test for https://github.com/drusepth/Indent/issues/378

  test 'user can log in to new accounts' do
    register_as 'Christopher Tolkien', 'tolkienjr@example.com', 'HiDad'
    log_out
    log_in_as 'Christopher Tolkien', 'HiDad'
    assert_equal dashboard_path, current_path, 'Users cannot log in to new accounts, regression of https://github.com/drusepth/Indent/issues/378'
  end
end
