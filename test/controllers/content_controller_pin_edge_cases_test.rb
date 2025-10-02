require 'test_helper'

class ContentControllerPinEdgeCasesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @character = characters(:one)
    sign_in @user
  end

  test "handles nil content gracefully for orphaned basil commission" do
    # Create an orphaned basil commission (entity is nil)
    orphaned_basil = BasilCommission.create!(
      user: @user,
      entity: nil,  # Orphaned - no associated content
      entity_type: 'Character',
      prompt: 'Test prompt',
      job_id: 'orphaned_123',
      pinned: false
    )

    post toggle_image_pin_path,
         params: { image_id: orphaned_basil.id, image_type: 'basil_commission' },
         headers: { 'Accept' => 'application/json' }

    assert_response :unprocessable_entity  # 422

    json_response = JSON.parse(response.body)
    assert_equal 'Content not found for this image', json_response['error']
  end

  test "handles nil pinned value correctly" do
    # Create an image with nil pinned value (simulating pre-migration data)
    image = ImageUpload.create!(
      user: @user,
      content_type: 'Character',
      content_id: @character.id,
      privacy: 'public'
    )

    # Force pinned to be nil to simulate edge case
    ActiveRecord::Base.connection.execute(
      "UPDATE image_uploads SET pinned = NULL WHERE id = #{image.id}"
    )
    image.reload

    # Verify pinned is nil
    assert_nil image.pinned

    post toggle_image_pin_path,
         params: { image_id: image.id, image_type: 'image_upload' },
         headers: { 'Accept' => 'application/json' }

    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response['pinned'], "Should pin when starting from nil"

    image.reload
    assert image.pinned
  end

  test "returns proper error for unauthenticated user" do
    sign_out @user

    image = image_uploads(:regular)

    post toggle_image_pin_path,
         params: { image_id: image.id, image_type: 'image_upload' },
         headers: { 'Accept' => 'application/json' }

    assert_response :unauthorized  # 401

    json_response = JSON.parse(response.body)
    # Devise returns this message when not authenticated
    assert_equal 'You need to sign in or sign up before continuing.', json_response['error']
  end

  test "handles concurrent pin requests without errors" do
    image1 = image_uploads(:regular)
    image2 = image_uploads(:pinned)

    threads = []

    # Simulate concurrent requests
    threads << Thread.new do
      post toggle_image_pin_path,
           params: { image_id: image1.id, image_type: 'image_upload' },
           headers: { 'Accept' => 'application/json' }
    end

    threads << Thread.new do
      post toggle_image_pin_path,
           params: { image_id: image2.id, image_type: 'image_upload' },
           headers: { 'Accept' => 'application/json' }
    end

    threads.each(&:join)

    # Both requests should complete without database lock errors
    # Only one should be pinned
    image1.reload
    image2.reload

    pinned_count = [image1, image2].count(&:pinned)
    assert_equal 1, pinned_count, "Exactly one image should be pinned after concurrent requests"
  end

  test "mixed type unpinning works correctly" do
    # Pin an image upload
    image = image_uploads(:regular)
    image.update!(pinned: true)

    # Create and pin a basil commission for the same content
    basil = BasilCommission.create!(
      user: @user,
      entity: @character,
      entity_type: 'Character',
      prompt: 'Test',
      job_id: 'test_123',
      pinned: false
    )

    # Pin the basil commission (should unpin the image upload)
    post toggle_image_pin_path,
         params: { image_id: basil.id, image_type: 'basil_commission' },
         headers: { 'Accept' => 'application/json' }

    assert_response :success

    image.reload
    basil.reload

    assert_not image.pinned, "Image upload should be unpinned"
    assert basil.pinned, "Basil commission should be pinned"

    # Now pin the image upload again (should unpin the basil)
    post toggle_image_pin_path,
         params: { image_id: image.id, image_type: 'image_upload' },
         headers: { 'Accept' => 'application/json' }

    assert_response :success

    image.reload
    basil.reload

    assert image.pinned, "Image upload should be pinned"
    assert_not basil.pinned, "Basil commission should be unpinned"
  end

  # Note: CSRF token testing is not reliable in test environment
  # as Rails often disables CSRF protection in tests.
  # This is better tested via system tests with JavaScript.
end