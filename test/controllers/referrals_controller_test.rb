require 'test_helper'

class ReferralsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get referrals_index_url
    assert_response :success
  end

end
