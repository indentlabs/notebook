require 'test_helper'

class PageTagsControllerTest < ActionDispatch::IntegrationTest
  test "should get remove" do
    get page_tags_remove_url
    assert_response :success
  end

end
