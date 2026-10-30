require 'test_helper'

class ContentImageTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @character = characters(:one)
    @character.update!(user: @user)

    @regular = image_uploads(:regular)
    @pinned  = image_uploads(:pinned)
    @private = image_uploads(:private)

    @basil = BasilCommission.create!(
      user: @user,
      entity: @character,
      prompt: 'A portrait',
      job_id: 'job-1',
      saved_at: Time.current,
      position: 4
    )
  end

  test "gallery_for returns uploads and saved Basil images in position order" do
    images = ContentImage.gallery_for(@character, viewer: @user)

    assert_equal ['upload-1', 'upload-2', 'upload-3', "basil-#{@basil.id}"], images.map(&:dom_id)
  end

  test "gallery_for hides private uploads from viewers who cannot manage the page" do
    dom_ids = ContentImage.gallery_for(@character, viewer: @other_user).map(&:dom_id)

    assert_includes dom_ids, 'upload-1'
    assert_not_includes dom_ids, 'upload-3'
  end

  test "gallery_for hides private uploads from anonymous viewers" do
    dom_ids = ContentImage.gallery_for(@character, viewer: nil).map(&:dom_id)

    assert_not_includes dom_ids, 'upload-3'
  end

  test "gallery_for skips Basil commissions that were never saved" do
    BasilCommission.create!(user: @user, entity: @character, prompt: 'Unsaved', job_id: 'job-2', saved_at: nil)

    basil_ids = ContentImage.gallery_for(@character, viewer: @user).select(&:basil?).map(&:id)
    assert_equal [@basil.id], basil_ids
  end

  test "wraps uploads with upload-specific paths and params" do
    image = ContentImage.wrap(@regular)

    assert image.upload?
    assert_equal 'upload', image.kind
    assert_equal 'image_upload', image.type_param
    assert_equal 'image_upload', image.param_key
    assert_equal Rails.application.routes.url_helpers.image_upload_path(@regular.id), image.update_path
    assert_equal Rails.application.routes.url_helpers.image_deletion_path(@regular.id), image.delete_path
    assert_includes image.pin_path, "image_type=image_upload"
    assert image.supports_privacy?
    assert image.public?
  end

  test "wraps Basil commissions with basil-specific paths and params" do
    image = ContentImage.wrap(@basil)

    assert image.basil?
    assert_equal 'basil', image.kind
    assert_equal 'basil_commission', image.type_param
    assert_equal 'basil_commission', image.param_key
    assert_equal Rails.application.routes.url_helpers.basil_commission_update_path(@basil.id), image.update_path
    assert_equal Rails.application.routes.url_helpers.basil_delete_path(@basil.id), image.delete_path
    assert_not image.supports_privacy?
    assert image.public?
    assert_nil image.url(:large), "an unattached Basil image has no URL"
  end

  test "cover? mirrors the pinned flag" do
    assert ContentImage.wrap(@pinned).cover?
    assert_not ContentImage.wrap(@regular).cover?
  end

  test "as_json exposes the fields the gallery JavaScript relies on" do
    json = ContentImage.wrap(@pinned).as_json

    assert_equal @pinned.id, json[:id]
    assert_equal 'upload-2', json[:dom_id]
    assert_equal true, json[:pinned]
    assert_equal 'public', json[:privacy]
    assert json.key?(:urls)
  end

  test "resolve_content only resolves classes that hold gallery images" do
    assert_equal @character, ContentImage.resolve_content('Character', @character.id)
    assert_nil ContentImage.resolve_content('User', @user.id)
    assert_nil ContentImage.resolve_content('NotAClass', 1)
    assert_nil ContentImage.resolve_content('Character', -1)
  end

  test "aspect_ratio, wide?, and narrow? classify image orientation" do
    @regular.update_columns(width: 600, height: 900)
    image = ContentImage.wrap(@regular)

    assert_in_delta 0.667, image.aspect_ratio, 0.01
    assert image.narrow?
    assert_not image.wide?

    @regular.update_columns(width: 1500, height: 500)
    assert_equal 3.0, image.aspect_ratio
    assert image.wide?
    assert_not image.narrow?

    @regular.update_columns(width: nil, height: nil)
    assert_nil image.aspect_ratio
    assert image.narrow?, "unknown dimensions default to narrow presentation"
    assert_not image.wide?
  end

  test "custom_crop? detects whether a crop was explicitly saved" do
    image = ContentImage.wrap(@regular)
    assert_not image.custom_crop?(:banner)

    @regular.update_columns(crops: { 'banner' => { 'x' => 0.1, 'y' => 0.1, 'w' => 0.8, 'h' => 0.4 } })
    assert image.custom_crop?(:banner)
    assert_not image.custom_crop?(:card)
  end

  test "display_url returns the uncropped derivative URL when attached" do
    assert_nil ContentImage.wrap(@regular).display_url

    upload = ImageUpload.create!(
      user: @user,
      content_type: 'Character',
      content_id: @character.id,
      src: Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/files/gallery_test.png'), 'image/png')
    )
    image = ContentImage.wrap(upload)
    assert_includes image.display_url, '/xlarge/'
  ensure
    upload&.destroy
  end
end
