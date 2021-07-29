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
    :writers_landing_url,
    :roleplayers_landing_url,
    :designers_landing_url,
    :redeem_infostack_url,
    :redeem_sascon_url
  ])

end
