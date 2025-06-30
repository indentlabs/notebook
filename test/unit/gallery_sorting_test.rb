require 'test_helper'

class GallerySortingTest < ActiveSupport::TestCase
  # Include the helper module directly
  include ApplicationHelper
  
  # Skip loading fixtures to avoid database issues
  self.use_transactional_tests = false
  
  # Create test classes that mimic needed behavior
  class MockImageUpload
    attr_reader :id, :created_at, :position, :pinned
    
    def initialize(id:, created_at: Time.current, position: nil, pinned: false)
      @id = id
      @created_at = created_at
      @position = position
      @pinned = pinned
    end
    
    def pinned?
      @pinned
    end
    
    def respond_to?(method)
      [:id, :created_at, :position, :pinned?].include?(method.to_sym)
    end
  end
  
  class MockBasilCommission
    attr_reader :id, :saved_at, :position, :pinned
    
    def initialize(id:, saved_at: Time.current, position: nil, pinned: false)
      @id = id
      @saved_at = saved_at
      @position = position
      @pinned = pinned
    end
    
    def pinned?
      @pinned
    end
    
    def respond_to?(method)
      [:id, :saved_at, :position, :pinned?].include?(method.to_sym)
    end
  end
  
  test "combine_and_sort_gallery_images should sort by position, not pinned status" do
    # Create images with different creation dates including a pinned one
    oldest = MockImageUpload.new(id: 1, created_at: 3.days.ago, position: 3)
    pinned = MockImageUpload.new(id: 2, created_at: 2.days.ago, pinned: true, position: 2)
    newest = MockImageUpload.new(id: 3, created_at: 1.day.ago, position: 1)
    
    # Call helper method
    result = combine_and_sort_gallery_images([oldest, pinned, newest], [])
    
    # Verify sorted by position, not pinned status
    assert_equal 3, result.size
    assert_equal 3, result[0][:data].id  # Position 1 should be first
    assert_equal 2, result[1][:data].id  # Position 2 should be second, even though pinned
    assert_equal 1, result[2][:data].id  # Position 3 should be third
  end
  
  test "combine_and_sort_gallery_images should respect position values" do
    # Images with specific positions regardless of creation date
    image1 = MockImageUpload.new(id: 1, created_at: 1.day.ago, position: 3)
    image2 = MockImageUpload.new(id: 2, created_at: 3.days.ago, position: 1)
    image3 = MockImageUpload.new(id: 3, created_at: 2.days.ago, position: 2)
    
    # Call helper method
    result = combine_and_sort_gallery_images([image1, image2, image3], [])
    
    # Verify they're sorted by position, not creation date
    assert_equal 2, result[0][:data].id  # position 1
    assert_equal 3, result[1][:data].id  # position 2
    assert_equal 1, result[2][:data].id  # position 3
  end
  
  test "combine_and_sort_gallery_images should handle mixed image types with positions" do
    # Create a mix of regular and basil images with positions
    image1 = MockImageUpload.new(id: 1, created_at: 1.day.ago, position: 3)
    image2 = MockImageUpload.new(id: 2, created_at: 3.days.ago, position: 1)
    basil1 = MockBasilCommission.new(id: 3, saved_at: 2.days.ago, position: 2)
    
    # Call helper method
    result = combine_and_sort_gallery_images([image1, image2], [basil1])
    
    # Verify they're sorted by position across types
    assert_equal 'image_upload', result[0][:type]
    assert_equal 2, result[0][:data].id  # position 1
    
    assert_equal 'basil_commission', result[1][:type]
    assert_equal 3, result[1][:data].id  # position 2
    
    assert_equal 'image_upload', result[2][:type]
    assert_equal 1, result[2][:data].id  # position 3
  end
  
  test "get_preview_image should prioritize pinned images" do
    # Create images with one of them pinned 
    image1 = MockImageUpload.new(id: 1, created_at: 3.days.ago, position: 1)
    image2 = MockImageUpload.new(id: 2, created_at: 2.days.ago, position: 2, pinned: true)
    image3 = MockImageUpload.new(id: 3, created_at: 1.day.ago, position: 3)
    
    # Call helper method
    result = get_preview_image([image1, image2, image3], [])
    
    # Verify the pinned image is returned
    assert_equal 2, result[:data].id  # Pinned should be selected
    assert result[:data].pinned?
  end
  
  test "get_preview_image should fall back to first sorted image when no pinned images exist" do
    # Images with no pinned status
    image1 = MockImageUpload.new(id: 1, created_at: 3.days.ago, position: 3)
    image2 = MockImageUpload.new(id: 2, created_at: 2.days.ago, position: 1)
    image3 = MockImageUpload.new(id: 3, created_at: 1.day.ago, position: 2)
    
    # Call helper method
    result = get_preview_image([image1, image2, image3], [])
    
    # Verify returns the first image by position
    assert_equal 2, result[:data].id  # Position 1 should be selected
  end
end