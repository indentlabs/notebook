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
    
    assert_response :unauthorized
    @image_upload.reload
    assert_nil @image_upload.notes
  end
end
