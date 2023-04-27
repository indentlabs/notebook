require "test_helper"

class ConversationControllerTest < ActionDispatch::IntegrationTest
  test "should get content" do
    get conversation_content_url
    assert_response :success
  end
end
