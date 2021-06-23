require 'test_helper'

class FoldersControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get folder_create_url
    assert_response :success
  end

  test "should get update" do
    get folder_update_url
    assert_response :success
  end

  test "should get destroy" do
    get folder_destroy_url
    assert_response :success
  end

end
