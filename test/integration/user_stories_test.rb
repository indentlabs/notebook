require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
  fixtures :users
  
  test 'creating a new user ends at the new user\'s dashboard' do
    register_as 'tester', 'test@example.com', 'password'
    
    assert_equal dashboard_path, current_path, 'New user was not directed to their dashboard after creating an account'
  end
  
  test 'logging in as an existing user goes to the users dashboard' do
    log_in_as 'TestUser', 'TestPassword'
    
    assert_equal dashboard_path, current_path, 'Existing user was not directed to their dashboard after logging in'
  end
  
  test 'logging in anonymousely goes into an empty dashboard' do
    log_in_as_anon
    
    assert_equal dashboard_path, current_path, 'Anonymous user was not directed to their dashboard after logging in'
  end
  
  ##
  # Regression test for bug #366
  
  test 'Anonymous flag is reset on user logins' do
    log_in_as_anon
    log_out
    log_in_as 'TestUser', 'TestPassword'
    refute page.has_content?('You are currently using an anonymous account'), 'Logged-in user was told they were using an anonymous account, regression of #366'
  end
end
