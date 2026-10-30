require "test_helper"

class ImageUploadControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one) # assuming standard fixtures
    @other_user = users(:two)
    
    # Create an image upload using fixtures or factories. 
    # Minitest using fixtures usually has image_uploads(:one).
    @image_upload = ImageUpload.create(
      user_id: @user.id,
      content_type: "Character",
      content_id: 1,
      privacy: "public"
    )
  end

  test "should update image notes if logged in as owner" do
    sign_in @user
    
    patch image_upload_path(@image_upload), params: {
      image_upload: {
        notes: "Here is a cool note"
      }
    }, as: :json
    
    assert_response :success
    @image_upload.reload
    assert_equal "Here is a cool note", @image_upload.notes
  end

  test "should not update image notes if not logged in" do
    patch image_upload_path(@image_upload), params: {
      image_upload: {
        notes: "Here is a cool note"
      }
    }, as: :json
    
    assert_response :unauthorized
    @image_upload.reload
    assert_nil @image_upload.notes
  end

  test "should not update image notes if not owner" do
    sign_in @other_user
    
    patch image_upload_path(@image_upload), params: {
      image_upload: {
        notes: "Here is a cool note"
      }
    }, as: :json
    
    assert_response :forbidden
    @image_upload.reload
    assert_nil @image_upload.notes
  end

  test "should update privacy as owner" do
    sign_in @user

    patch image_upload_path(@image_upload), params: { image_upload: { privacy: "private" } }, as: :json

    assert_response :success
    assert_equal "private", @image_upload.reload.privacy
    assert_equal "private", JSON.parse(response.body).dig("image", "privacy")
  end

  test "should not update image that does not exist" do
    sign_in @user

    patch image_upload_path(-1), params: { image_upload: { notes: "x" } }, as: :json

    assert_response :not_found
  end

  test "should delete an image and credit the uploader's bandwidth" do
    sign_in @user
    @user.update!(upload_bandwidth_kb: 100)
    @image_upload.update_columns(src_file_size: 50_000)

    delete image_deletion_path(@image_upload), as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal true, body["success"]
    assert_in_delta 50.0, body["reclaimed_kb"], 0.01
    assert_in_delta 150.0, body["remaining_kb"], 0.01
    assert_nil ImageUpload.find_by(id: @image_upload.id)
  end

  test "should not delete an image as a stranger" do
    sign_in @other_user

    delete image_deletion_path(@image_upload), as: :json

    assert_response :forbidden
    assert ImageUpload.exists?(@image_upload.id)
  end

  test "should create an image through the JSON endpoint and return a card" do
    sign_in @user
    @user.update!(upload_bandwidth_kb: 500)

    assert_difference "ImageUpload.count", 1 do
      post image_uploads_path, params: {
        content_type: "Character",
        content_id: 1,
        src: fixture_file_upload("gallery_test.png", "image/png")
      }, headers: { "Accept" => "application/json" }
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal true, body["success"]
    assert_includes body["html"], "gallery-card"
    assert_includes body["html"], "data-gallery-target=\"card\""
    assert body["remaining_kb"] < 500
    assert_equal "public", body.dig("image", "privacy")
  end

  test "should reject uploads from users who cannot edit the page" do
    sign_in @other_user

    assert_no_difference "ImageUpload.count" do
      post image_uploads_path, params: {
        content_type: "Character",
        content_id: 1,
        src: fixture_file_upload("gallery_test.png", "image/png")
      }, headers: { "Accept" => "application/json" }
    end

    assert_response :forbidden
  end

  test "should reject uploads for unknown pages" do
    sign_in @user

    post image_uploads_path, params: {
      content_type: "User",
      content_id: @user.id,
      src: fixture_file_upload("gallery_test.png", "image/png")
    }, headers: { "Accept" => "application/json" }

    assert_response :not_found
  end

  test "should explain when the upload quota is exhausted" do
    sign_in @user
    @user.update!(upload_bandwidth_kb: 0)

    assert_no_difference "ImageUpload.count" do
      post image_uploads_path, params: {
        content_type: "Character",
        content_id: 1,
        src: fixture_file_upload("gallery_test.png", "image/png")
      }, headers: { "Accept" => "application/json" }
    end

    assert_response :unprocessable_entity
    assert_match(/upload bandwidth/, JSON.parse(response.body)["error"])
  end
end
