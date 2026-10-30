require 'test_helper'

class NoticeDismissalControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  
  setup do
    @user = users(:one)
  end

  test "should dismiss notice when authenticated" do
    sign_in @user
    
    # Test dismissing a notice - this tests the basic functionality
    get notice_dismissal_dismiss_path, params: { notice_type: 'test_notice' }, headers: { 'Accept' => 'application/json' }
    
    # The notice dismissal redirects to /my/dashboard after successful dismissal
    assert_response :redirect
    assert_redirected_to '/my/dashboard'
  end

  test "should require authentication for notice dismissal" do
    # Try to dismiss without authentication
    get notice_dismissal_dismiss_path, params: { notice_type: 'test_notice' }, headers: { 'Accept' => 'application/json' }
    
    # Should return unauthorized for JSON requests
    assert_response :unauthorized
  end
end
