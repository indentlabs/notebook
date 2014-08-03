require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
  test 'creating a new user' do
    visit homepage_path
    click_on 'Register'
    fill_in 'Name', :with => 'tester'
    fill_in 'Email', :with => 'test@example.com'
    fill_in 'Password', :with => 'password'
    click_on 'Create User'
    
    assert_equal dashboard_path, current_path, 'New user was not redirected to their dashboard after creating an account'
  end
end
