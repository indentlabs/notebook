require 'test_helper'

class PageCollectionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
  end

  test "content type action redirects when collection does not exist" do
    sign_in @user

    get characters_page_collection_path(id: 'card-headers')

    assert_redirected_to root_path
    assert_equal 'Collection not found!', flash[:notice]
  end

  test "pages action redirects when collection does not exist" do
    sign_in @user

    get pages_page_collection_path(id: 'card-headers')

    assert_redirected_to root_path
    assert_equal 'Collection not found!', flash[:notice]
  end
end
