require 'test_helper'

class ContentImageHelperTest < ActionView::TestCase
  include ContentImageHelper

  setup do
    @user = users(:one)
    @character = characters(:one)
    @character.update!(user: @user)
    @user.update!(upload_bandwidth_kb: 5000)
    ImageUpload.where(content_type: 'Character', content_id: @character.id).delete_all
  end

  teardown do
    @upload&.destroy
  end

  test "renders the content type placeholder when there are no images" do
    html = content_image_tag(@character, :card, class: 'w-full')

    assert_includes html, 'card-headers/characters'
    assert_includes html, 'class="w-full"'
    assert_includes html, 'placeholder image'
  end

  test "serves the preset derivative when it has been generated" do
    @upload = create_upload
    html = content_image_tag(@character, :banner, class: 'hero')

    assert_includes html, '/banner/'
    assert_not_includes html, 'object-position'
    assert_not_includes html, 'loading="lazy"', 'banners are above the fold'
  end

  test "falls back to a general size with the focal point when derivatives are missing" do
    @upload = create_upload
    @upload.update_columns(crops_generated_at: nil, focal_x: 0.25, focal_y: 0.75)
    @character.clear_cover_image_cache

    html = content_image_tag(@character, :card, class: 'card')

    assert_includes html, '/large/'
    assert_includes html, 'object-position: 25.0% 75.0%'
    assert_includes html, 'loading="lazy"'
  end

  test "hides private images unless include_private is set" do
    @upload = create_upload(privacy: 'private')

    public_html = content_image_tag(@character, :card)
    assert_includes public_html, 'card-headers/characters'

    @character.clear_cover_image_cache
    private_html = content_image_tag(@character, :card, include_private: true)
    assert_includes private_html, '/card/'
  end

  test "uses notes as alt text when present" do
    @upload = create_upload
    @upload.update!(notes: 'Amelia at the harbour')
    @character.clear_cover_image_cache

    assert_includes content_image_tag(@character, :square), 'alt="Amelia at the harbour"'
  end

  test "social image url prefers the card framing" do
    @upload = create_upload

    # In production Paperclip returns an absolute S3 URL; locally it is a path.
    assert_includes content_social_image_url(@character), '/card/'
  end

  test "pinned images win over earlier ones" do
    first = create_upload
    @upload = create_upload
    @upload.update_columns(pinned: true)
    @character.clear_cover_image_cache

    assert_equal @upload.id, @character.cover_image(include_private: true).id
  ensure
    first&.destroy
  end

  private

  def create_upload(privacy: 'public')
    ImageUpload.create!(
      user: @user,
      content_type: 'Character',
      content_id: @character.id,
      privacy: privacy,
      src: Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/files/gallery_test.png'), 'image/png')
    )
  end
end
