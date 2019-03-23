require 'test_helper'

class PromptsControllerTest < ActionDispatch::IntegrationTest
  test "should get notebook" do
    get prompts_notebook_url
    assert_response :success
  end

  test "should get image" do
    get prompts_image_url
    assert_response :success
  end

end
