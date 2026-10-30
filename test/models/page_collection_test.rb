require 'test_helper'

class PageCollectionTest < ActiveSupport::TestCase
  setup do
    @collection = page_collections(:one)
  end

  test "uses the placeholder header when it has no image of its own" do
    @collection.cover_image = nil

    assert_not @collection.custom_header_image?
    assert_includes @collection.header_image_url, 'card-headers/pagecollections'
  end

  test "prefers the legacy cover_image URL" do
    @collection.cover_image = 'https://example.com/legacy.png'

    assert @collection.custom_header_image?
    assert_equal 'https://example.com/legacy.png', @collection.header_image_url
  end

  test "uses an uploaded header image" do
    @collection.cover_image = nil
    @collection.header_image.attach(
      io: File.open(Rails.root.join('test/fixtures/files/gallery_test.png')),
      filename: 'header.png',
      content_type: 'image/png'
    )

    assert @collection.custom_header_image?
    assert_equal @collection.header_image, @collection.header_image_url
  end
end
