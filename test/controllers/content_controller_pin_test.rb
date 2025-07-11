require 'test_helper'

class ContentControllerPinTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  
  setup do
    @user = users(:one)
    @character = characters(:one)
    @image_upload = image_uploads(:regular)
    @pinned_image = image_uploads(:pinned)
    
    # Create a test basil commission
    @basil_commission = BasilCommission.create!(
      user: @user,
      entity: @character,
      entity_type: 'Character',
      prompt: 'Test prompt',
      job_id: 'test_job_123',
      pinned: false
    )
    
    sign_in @user
  end

  test "should pin an unpinned image upload" do
    assert_not @image_upload.pinned, "Image should start unpinned"
    
    post toggle_image_pin_path, 
         params: { image_id: @image_upload.id, image_type: 'image_upload' },
         headers: { 'Accept' => 'application/json' }
    
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal @image_upload.id, json_response['id']
    assert_equal 'image_upload', json_response['type']
    assert json_response['pinned'], "Response should indicate image is now pinned"
    
    @image_upload.reload
    assert @image_upload.pinned, "Image should be pinned in database"
  end

  test "should unpin a pinned image upload" do
    assert @pinned_image.pinned, "Image should start pinned"
    
    post toggle_image_pin_path, 
         params: { image_id: @pinned_image.id, image_type: 'image_upload' },
         headers: { 'Accept' => 'application/json' }
    
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal @pinned_image.id, json_response['id']
    assert_equal 'image_upload', json_response['type']
    assert_not json_response['pinned'], "Response should indicate image is now unpinned"
    
    @pinned_image.reload
    assert_not @pinned_image.pinned, "Image should be unpinned in database"
  end

  test "should pin a basil commission" do
    assert_not @basil_commission.pinned, "Basil commission should start unpinned"
    
    post toggle_image_pin_path, 
         params: { image_id: @basil_commission.id, image_type: 'basil_commission' },
         headers: { 'Accept' => 'application/json' }
    
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal @basil_commission.id, json_response['id']
    assert_equal 'basil_commission', json_response['type']
    assert json_response['pinned'], "Response should indicate basil commission is now pinned"
    
    @basil_commission.reload
    assert @basil_commission.pinned, "Basil commission should be pinned in database"
  end

  test "should unpin previously pinned basil commission" do
    @basil_commission.update!(pinned: true)
    
    post toggle_image_pin_path, 
         params: { image_id: @basil_commission.id, image_type: 'basil_commission' },
         headers: { 'Accept' => 'application/json' }
    
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_not json_response['pinned'], "Response should indicate basil commission is now unpinned"
    
    @basil_commission.reload
    assert_not @basil_commission.pinned, "Basil commission should be unpinned in database"
  end

  test "pinning an image should unpin other images for same content" do
    # Ensure we have a pinned image and an unpinned image for the same character
    @pinned_image.update!(pinned: true)
    @image_upload.update!(pinned: false)
    
    # Pin the unpinned image
    post toggle_image_pin_path, 
         params: { image_id: @image_upload.id, image_type: 'image_upload' },
         headers: { 'Accept' => 'application/json' }
    
    assert_response :success
    
    # Check that the previously pinned image is now unpinned
    @pinned_image.reload
    @image_upload.reload
    
    assert_not @pinned_image.pinned, "Previously pinned image should be unpinned"
    assert @image_upload.pinned, "Newly pinned image should be pinned"
  end

  test "pinning an image should unpin basil commissions for same content" do
    @basil_commission.update!(pinned: true)
    
    post toggle_image_pin_path, 
         params: { image_id: @image_upload.id, image_type: 'image_upload' },
         headers: { 'Accept' => 'application/json' }
    
    assert_response :success
    
    @basil_commission.reload
    @image_upload.reload
    
    assert_not @basil_commission.pinned, "Basil commission should be unpinned"
    assert @image_upload.pinned, "Image upload should be pinned"
  end

  test "pinning a basil commission should unpin image uploads for same content" do
    @pinned_image.update!(pinned: true)
    
    post toggle_image_pin_path, 
         params: { image_id: @basil_commission.id, image_type: 'basil_commission' },
         headers: { 'Accept' => 'application/json' }
    
    assert_response :success
    
    @pinned_image.reload
    @basil_commission.reload
    
    assert_not @pinned_image.pinned, "Image upload should be unpinned"
    assert @basil_commission.pinned, "Basil commission should be pinned"
  end

  test "should return error for non-existent image" do
    post toggle_image_pin_path, 
         params: { image_id: 99999, image_type: 'image_upload' },
         headers: { 'Accept' => 'application/json' }
    
    assert_response :not_found
    
    json_response = JSON.parse(response.body)
    assert_equal 'Image not found', json_response['error']
  end

  test "should return error for invalid image type" do
    post toggle_image_pin_path, 
         params: { image_id: @image_upload.id, image_type: 'invalid_type' },
         headers: { 'Accept' => 'application/json' }
    
    assert_response :bad_request
    
    json_response = JSON.parse(response.body)
    assert_equal 'Invalid image type', json_response['error']
  end

  test "should return unauthorized for other user's content" do
    other_user = users(:two)
    other_character = characters(:two)
    other_image = ImageUpload.create!(
      user: other_user,
      content_type: 'Character',
      content_id: other_character.id,
      privacy: 'public'
    )
    
    post toggle_image_pin_path, 
         params: { image_id: other_image.id, image_type: 'image_upload' },
         headers: { 'Accept' => 'application/json' }
    
    assert_response :forbidden
    
    json_response = JSON.parse(response.body)
    assert_equal 'Unauthorized', json_response['error']
  end

  test "should require authentication" do
    sign_out @user
    
    post toggle_image_pin_path, 
         params: { image_id: @image_upload.id, image_type: 'image_upload' },
         headers: { 'Accept' => 'application/json' }
    
    assert_response :unauthorized
  end

  # Using Devise::Test::IntegrationHelpers for sign_in/sign_out
end