require 'test_helper'

class Api::V1::GalleryImagesControllerTest < ActionDispatch::IntegrationTest
  # Skip the automatically generated smoke test since there's no root URL for this controller
  def test_should_get_root_url
    skip("No root URL for gallery images controller")
  end
  include Devise::Test::IntegrationHelpers
  
  setup do
    # Create a user for testing
    @user = users(:one)
    
    # Create a character owned by this user
    @character = characters(:one)
    @character.update(user: @user)
    
    # Create some test images
    @image1 = ImageUpload.create!(
      user: @user,
      content_type: "Character",
      content_id: @character.id,
      privacy: "public",
      position: 2
    )
    
    @image2 = ImageUpload.create!(
      user: @user,
      content_type: "Character",
      content_id: @character.id,
      privacy: "public",
      position: 1
    )
    
    # Create a test basil commission
    @commission = BasilCommission.create!(
      user: @user,
      entity_type: "Character",
      entity_id: @character.id,
      position: 3
    )
    
    # Sign in as the user
    sign_in @user
  end
  
  test "should update image positions" do
    # Prepare the sorting data
    sort_data = {
      images: [
        { id: @image1.id, type: 'image_upload', position: 3 },
        { id: @commission.id, type: 'basil_commission', position: 1 },
        { id: @image2.id, type: 'image_upload', position: 2 }
      ],
      content_type: "Character",
      content_id: @character.id
    }
    
    # Send the request
    post api_v1_gallery_images_sort_path, params: sort_data, as: :json
    
    # Check response
    assert_response :success
    assert_equal true, JSON.parse(response.body)["success"]
    
    # Reload the records to check positions
    @image1.reload
    @image2.reload
    @commission.reload
    
    assert_equal 3, @image1.position
    assert_equal 2, @image2.position
    assert_equal 1, @commission.position
  end
  
  test "should not update positions for unauthorized user" do
    # Create another user
    @other_user = User.create!(
      email: 'other@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
    
    # Sign in as the other user
    sign_in @other_user
    
    # Prepare the sorting data
    sort_data = {
      images: [
        { id: @image1.id, type: 'image_upload', position: 3 },
        { id: @commission.id, type: 'basil_commission', position: 1 },
        { id: @image2.id, type: 'image_upload', position: 2 }
      ],
      content_type: "Character",
      content_id: @character.id
    }
    
    # Send the request
    post api_v1_gallery_images_sort_path, params: sort_data, as: :json
    
    # Check response - should be unauthorized
    assert_response :unauthorized
    
    # Positions should remain unchanged
    @image1.reload
    @image2.reload
    @commission.reload
    
    assert_equal 3, @image1.position
    assert_equal 1, @image2.position
    assert_equal 3, @commission.position
  end
  
  test "should handle invalid image ids" do
    # Prepare sorting data with a non-existent image
    sort_data = {
      images: [
        { id: 9999, type: 'image_upload', position: 1 },
        { id: @image1.id, type: 'image_upload', position: 2 }
      ],
      content_type: "Character",
      content_id: @character.id
    }
    
    # Send the request
    post api_v1_gallery_images_sort_path, params: sort_data, as: :json
    
    # Check response - should be unprocessable entity
    assert_response :unprocessable_entity
    
    # Positions should remain unchanged
    @image1.reload
    @image2.reload
    
    assert_equal 3, @image1.position
    assert_equal 1, @image2.position
  end
  
  test "should handle invalid image types" do
    # Prepare sorting data with an invalid image type
    sort_data = {
      images: [
        { id: @image1.id, type: 'invalid_type', position: 1 }
      ],
      content_type: "Character",
      content_id: @character.id
    }
    
    # Send the request
    post api_v1_gallery_images_sort_path, params: sort_data, as: :json
    
    # Check response - should be unprocessable entity
    assert_response :unprocessable_entity
    
    # Position should remain unchanged
    @image1.reload
    assert_equal 3, @image1.position
  end
end