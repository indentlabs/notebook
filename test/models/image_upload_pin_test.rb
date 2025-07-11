require 'test_helper'

class ImageUploadPinTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @character = characters(:one)
  end

  test "should allow setting pinned to true" do
    image = ImageUpload.new(
      user: @user,
      content_type: 'Character',
      content_id: @character.id,
      privacy: 'public',
      pinned: true
    )
    
    assert image.valid?, "Image with pinned=true should be valid"
    assert image.pinned, "Image should be pinned"
  end

  test "should allow setting pinned to false" do
    image = ImageUpload.new(
      user: @user,
      content_type: 'Character',
      content_id: @character.id,
      privacy: 'public',
      pinned: false
    )
    
    assert image.valid?, "Image with pinned=false should be valid"
    assert_not image.pinned, "Image should not be pinned"
  end

  test "should default pinned to false if not specified" do
    image = ImageUpload.new(
      user: @user,
      content_type: 'Character',
      content_id: @character.id,
      privacy: 'public'
    )
    
    assert_not image.pinned, "Image should default to not pinned"
  end

  test "pinned scope should return only pinned images" do
    pinned_image = ImageUpload.create!(
      user: @user,
      content_type: 'Character',
      content_id: @character.id,
      privacy: 'public',
      pinned: true
    )
    
    unpinned_image = ImageUpload.create!(
      user: @user,
      content_type: 'Character',
      content_id: @character.id,
      privacy: 'public',
      pinned: false
    )
    
    pinned_images = ImageUpload.pinned
    
    assert_includes pinned_images, pinned_image
    assert_not_includes pinned_images, unpinned_image
  end

  test "should update pinned status without triggering callbacks" do
    image = ImageUpload.create!(
      user: @user,
      content_type: 'Character',
      content_id: @character.id,
      privacy: 'public',
      pinned: false
    )
    
    # This simulates what the controller does
    image.update_column(:pinned, true)
    
    assert image.reload.pinned, "Image should be pinned after update_column"
  end

  test "multiple images can exist for same content with different pin status" do
    image1 = ImageUpload.create!(
      user: @user,
      content_type: 'Character',
      content_id: @character.id,
      privacy: 'public',
      pinned: true
    )
    
    image2 = ImageUpload.create!(
      user: @user,
      content_type: 'Character',
      content_id: @character.id,
      privacy: 'public',
      pinned: false
    )
    
    assert image1.valid?
    assert image2.valid?
    assert image1.pinned
    assert_not image2.pinned
  end

  test "should be able to query pinned images for specific content" do
    # Create images for character 1
    char1_pinned = ImageUpload.create!(
      user: @user,
      content_type: 'Character',
      content_id: @character.id,
      privacy: 'public',
      pinned: true
    )
    
    char1_unpinned = ImageUpload.create!(
      user: @user,
      content_type: 'Character',
      content_id: @character.id,
      privacy: 'public',
      pinned: false
    )
    
    # Create image for character 2
    char2 = characters(:two)
    char2_pinned = ImageUpload.create!(
      user: users(:two),
      content_type: 'Character',
      content_id: char2.id,
      privacy: 'public',
      pinned: true
    )
    
    # Query pinned images for character 1 only
    char1_pinned_images = ImageUpload.where(
      content_type: 'Character',
      content_id: @character.id,
      pinned: true
    )
    
    # Should include our newly created image plus any fixture images
    assert char1_pinned_images.count >= 1, "Should have at least one pinned image"
    assert_includes char1_pinned_images, char1_pinned
    assert_not_includes char1_pinned_images, char1_unpinned
    assert_not_includes char1_pinned_images, char2_pinned
  end
end