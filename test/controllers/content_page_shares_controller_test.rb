require 'test_helper'

class ContentPageSharesControllerTest < ActionDispatch::IntegrationTest
  # PageCollection's legacy cover_image column used to be mistaken for the
  # gallery API, raising ArgumentError when a shared collection was shown.
  test "shows a shared page collection with a legacy cover image" do
    user = users(:one)
    collection = page_collections(:one)
    collection.update_columns(privacy: 'public', cover_image: 'https://example.com/collection-cover.png')
    share = ContentPageShare.create!(
      user: user,
      content_page: collection,
      content_page_type: 'PageCollection',
      shared_at: Time.current,
      privacy: 'public'
    )

    get user_content_page_share_path(user, share)

    assert_response :success
    assert_includes response.body, 'https://example.com/collection-cover.png'
  end
end
