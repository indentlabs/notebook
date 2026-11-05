require 'test_helper'

class ContentPageSharesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

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

  # destroy used to redirect to content_page_shares_url, which doesn't exist
  # (shares are only routed under users), so deleting a share was a 500.
  test "owner can delete their share and is sent back to the stream" do
    user = users(:one)
    collection = page_collections(:one)
    collection.update_columns(privacy: 'public')
    share = ContentPageShare.create!(
      user: user,
      content_page: collection,
      content_page_type: 'PageCollection',
      shared_at: Time.current,
      privacy: 'public'
    )

    sign_in user
    delete user_content_page_share_path(user, share)

    assert_redirected_to stream_path
    assert_nil ContentPageShare.find_by(id: share.id)
  end
end
