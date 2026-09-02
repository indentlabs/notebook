require 'test_helper'

class Content::ShowGalleryTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @stranger = users(:two)
    @character = characters(:one)
    @character.update!(user: @user, privacy: 'public')
    @user.update!(upload_bandwidth_kb: 5000)
    ImageUpload.where(content_type: 'Character', content_id: @character.id).delete_all

    @public_image  = create_upload(privacy: 'public', notes: 'Amelia at the harbour')
    @private_image = create_upload(privacy: 'private')
  end

  teardown do
    @public_image&.destroy
    @private_image&.destroy
  end

  test "owner sees every image in a lightbox grid served from derivatives" do
    sign_in @user
    get character_path(@character)

    assert_response :success
    assert_includes response.body, 'data-controller="lightbox"'
    assert_includes response.body, "data-image-id=\"upload-#{@public_image.id}\""
    assert_includes response.body, "data-image-id=\"upload-#{@private_image.id}\""
    assert_includes response.body, '/large/'
    assert_includes response.body, '/xlarge/'
    assert_includes response.body, 'Amelia at the harbour'
    assert_includes response.body, "#gallery/upload-#{@public_image.id}", 'editors get an Edit framing deep link'
    assert_not_includes response.body, 'openImageModal'
  end

  test "strangers only see public images and no edit link" do
    sign_in @stranger
    get character_path(@character)

    assert_response :success
    assert_includes response.body, "data-image-id=\"upload-#{@public_image.id}\""
    assert_not_includes response.body, "data-image-id=\"upload-#{@private_image.id}\""
    assert_not_includes response.body, "#gallery/upload-#{@public_image.id}"
  end

  private

  def create_upload(privacy:, notes: nil)
    ImageUpload.create!(
      user: @user,
      content_type: 'Character',
      content_id: @character.id,
      privacy: privacy,
      notes: notes,
      src: Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/files/gallery_test.png'), 'image/png')
    )
  end
end
