require 'test_helper'

class PaperControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get paper_index_url
    assert_response :success
  end

  test "should get generate" do
    get paper_generate_url
    assert_response :success
  end

end
