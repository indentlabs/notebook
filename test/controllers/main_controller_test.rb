require 'test_helper'

class MainControllerTest < ActionDispatch::IntegrationTest
  test "should get root path" do
    get root_url
    assert_response :success
  end

  test "should get privacy page" do
    get privacy_policy_url
    assert_response :success
  end

  SmokeTest.urls([
    :root_url,
    :privacy_policy_url,
    :dice
  ])

end
