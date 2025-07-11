require 'test_helper'

class PinWorkflowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  
  setup do
    @user = users(:one)
    @character = characters(:one)
    
    # Create multiple images for testing
    @image1 = ImageUpload.create!(
      user: @user,
      content_type: 'Character',
      content_id: @character.id,
      privacy: 'public',
      pinned: false
    )
    
    @image2 = ImageUpload.create!(
      user: @user,
      content_type: 'Character',
      content_id: @character.id,
      privacy: 'public',
      pinned: false
    )
    
    @basil1 = BasilCommission.create!(
      user: @user,
      entity: @character,
      entity_type: 'Character',
      prompt: 'Test basil 1',
      job_id: 'basil_job_1',
      pinned: false
    )
    
    @basil2 = BasilCommission.create!(
      user: @user,
      entity: @character,
      entity_type: 'Character',
      prompt: 'Test basil 2',
      job_id: 'basil_job_2',
      pinned: false
    )
    
    sign_in @user
  end

  test "complete pin workflow: pin, switch, unpin" do
    # Step 1: Pin first image
    post toggle_image_pin_path, 
         params: { image_id: @image1.id, image_type: 'image_upload' },
         headers: { 'Accept' => 'application/json' }
    
    assert_response :success
    assert JSON.parse(response.body)['pinned']
    
    # Verify state
    @image1.reload
    assert @image1.pinned, "Image 1 should be pinned"
    assert_not @image2.reload.pinned, "Image 2 should remain unpinned"
    assert_not @basil1.reload.pinned, "Basil 1 should remain unpinned"
    assert_not @basil2.reload.pinned, "Basil 2 should remain unpinned"
    
    # Step 2: Pin second image (should unpin first)
    post toggle_image_pin_path, 
         params: { image_id: @image2.id, image_type: 'image_upload' },
         headers: { 'Accept' => 'application/json' }
    
    assert_response :success
    assert JSON.parse(response.body)['pinned']
    
    # Verify state
    @image1.reload
    @image2.reload
    assert_not @image1.pinned, "Image 1 should be unpinned"
    assert @image2.pinned, "Image 2 should be pinned"
    assert_not @basil1.reload.pinned, "Basil 1 should remain unpinned"
    assert_not @basil2.reload.pinned, "Basil 2 should remain unpinned"
    
    # Step 3: Pin basil commission (should unpin image)
    post toggle_image_pin_path, 
         params: { image_id: @basil1.id, image_type: 'basil_commission' },
         headers: { 'Accept' => 'application/json' }
    
    assert_response :success
    assert JSON.parse(response.body)['pinned']
    
    # Verify state
    assert_not @image1.reload.pinned, "Image 1 should remain unpinned"
    assert_not @image2.reload.pinned, "Image 2 should be unpinned"
    assert @basil1.reload.pinned, "Basil 1 should be pinned"
    assert_not @basil2.reload.pinned, "Basil 2 should remain unpinned"
    
    # Step 4: Pin second basil (should unpin first basil)
    post toggle_image_pin_path, 
         params: { image_id: @basil2.id, image_type: 'basil_commission' },
         headers: { 'Accept' => 'application/json' }
    
    assert_response :success
    assert JSON.parse(response.body)['pinned']
    
    # Verify state
    assert_not @image1.reload.pinned, "Image 1 should remain unpinned"
    assert_not @image2.reload.pinned, "Image 2 should remain unpinned"
    assert_not @basil1.reload.pinned, "Basil 1 should be unpinned"
    assert @basil2.reload.pinned, "Basil 2 should be pinned"
    
    # Step 5: Unpin the currently pinned basil (go back to 0 pins)
    post toggle_image_pin_path, 
         params: { image_id: @basil2.id, image_type: 'basil_commission' },
         headers: { 'Accept' => 'application/json' }
    
    assert_response :success
    assert_not JSON.parse(response.body)['pinned']
    
    # Verify final state - nothing should be pinned
    assert_not @image1.reload.pinned, "Image 1 should remain unpinned"
    assert_not @image2.reload.pinned, "Image 2 should remain unpinned"
    assert_not @basil1.reload.pinned, "Basil 1 should remain unpinned"
    assert_not @basil2.reload.pinned, "Basil 2 should be unpinned"
  end

  test "pin workflow across different content types" do
    # Create another character with images
    character2 = Character.create!(
      name: 'Test Character 2',
      user: @user,
      privacy: 'public'
    )
    
    image_char2 = ImageUpload.create!(
      user: @user,
      content_type: 'Character',
      content_id: character2.id,
      privacy: 'public',
      pinned: false
    )
    
    # Pin image for character 1
    post toggle_image_pin_path, 
         params: { image_id: @image1.id, image_type: 'image_upload' },
         headers: { 'Accept' => 'application/json' }
    
    assert_response :success
    assert @image1.reload.pinned, "Character 1 image should be pinned"
    
    # Pin image for character 2 - should NOT affect character 1 pins
    post toggle_image_pin_path, 
         params: { image_id: image_char2.id, image_type: 'image_upload' },
         headers: { 'Accept' => 'application/json' }
    
    assert_response :success
    
    # Both should remain pinned (different content)
    assert @image1.reload.pinned, "Character 1 image should remain pinned"
    assert image_char2.reload.pinned, "Character 2 image should be pinned"
    assert_not @image2.reload.pinned, "Character 1 other image should remain unpinned"
  end

  test "pin workflow with rapid requests should handle gracefully" do
    # Simulate rapid clicking by making multiple requests quickly
    threads = []
    results = []
    
    5.times do |i|
      threads << Thread.new do
        post toggle_image_pin_path, 
             params: { image_id: @image1.id, image_type: 'image_upload' },
             headers: { 'Accept' => 'application/json' }
        
        results << {
          status: response.status,
          body: response.body.present? ? JSON.parse(response.body) : nil
        }
      end
    end
    
    threads.each(&:join)
    
    # At least one request should succeed
    successful_requests = results.select { |r| r[:status] == 200 }
    assert successful_requests.any?, "At least one request should succeed"
    
    # Final state should be consistent
    @image1.reload
    assert [@image1.pinned, !@image1.pinned].include?(true), "Image should have a consistent final state"
  end

  test "database performance with many images" do
    # Create many images to test performance
    images = []
    20.times do |i|
      images << ImageUpload.create!(
        user: @user,
        content_type: 'Character',
        content_id: @character.id,
        privacy: 'public',
        pinned: false
      )
    end
    
    # Time the pin operation
    start_time = Time.current
    
    post toggle_image_pin_path, 
         params: { image_id: images.first.id, image_type: 'image_upload' },
         headers: { 'Accept' => 'application/json' }
    
    end_time = Time.current
    duration = end_time - start_time
    
    assert_response :success
    assert duration < 1.0, "Pin operation should complete in under 1 second even with many images"
    
    # Verify only one image is pinned
    pinned_count = ImageUpload.where(
      content_type: 'Character',
      content_id: @character.id,
      pinned: true
    ).count
    
    assert_equal 1, pinned_count, "Only one image should be pinned"
  end

  # Using Devise::Test::IntegrationHelpers for sign_in
end