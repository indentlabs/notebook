require 'test_helper'

class HasImageFramingTest < ActiveSupport::TestCase
  setup do
    @image = image_uploads(:regular)
    @image.update_columns(width: 2000, height: 1000)
  end

  test "defaults to a centred focal point with no crops" do
    assert_equal [0.5, 0.5], @image.focal_point
    assert_equal({}, @image.crops)
    assert_equal '50.0% 50.0%', @image.object_position_css
    assert_not @image.any_custom_crops?
  end

  test "auto crop fits the preset shape inside the image around the focal point" do
    @image.update!(focal_x: 0.9, focal_y: 0.5)

    banner = @image.auto_crop_for(:banner)
    assert_equal 1.0, banner[:w], "a 2:1 image is narrower than 3:1, so the banner spans the full width"
    assert_in_delta 0.6667, banner[:h], 0.0001
    assert_in_delta 0.0, banner[:x], 0.0001
    assert_in_delta 0.1667, banner[:y], 0.0001

    square = @image.auto_crop_for(:square)
    assert_equal 1.0, square[:h]
    assert_in_delta 0.5, square[:w], 0.0001
    assert_in_delta 0.5, square[:x], 0.0001, "square crop is pushed to the right edge, not past it"
  end

  test "auto crop is nil without known dimensions" do
    @image.update_columns(width: nil, height: nil)
    assert_nil @image.auto_crop_for(:card)
  end

  test "accepts well-formed crops and normalises them" do
    @image.crops = { 'banner' => { 'x' => '0.1', 'y' => 0, 'w' => 0.6, 'h' => 0.4 }, 'bogus' => { x: 0, y: 0, w: 1, h: 1 } }

    assert @image.valid?, @image.errors.full_messages.to_sentence
    assert_equal({ 'banner' => { 'x' => 0.1, 'y' => 0.0, 'w' => 0.6, 'h' => 0.4 } }, @image.crops)
    assert @image.custom_crop?(:banner)
    assert_not @image.custom_crop?(:card)
    assert_equal({ x: 0.1, y: 0.0, w: 0.6, h: 0.4 }, @image.crop_for(:banner))
  end

  test "rejects crops with the wrong aspect ratio" do
    @image.crops = { 'square' => { x: 0, y: 0, w: 0.5, h: 0.5 } } # 1000x500 px, not square

    assert_not @image.valid?
    assert_match(/Square crop must be 1:1/, @image.errors[:crops].to_sentence)
  end

  test "rejects crops that leave the image" do
    @image.crops = { 'card' => { x: 0.8, y: 0.2, w: 0.6, h: 0.8 } }

    assert_not @image.valid?
    assert_match(/outside the image/, @image.errors[:crops].to_sentence)
  end

  test "drops empty crop entries so a shape can be reset" do
    @image.update!(crops: { 'banner' => { x: 0.0, y: 0.0, w: 1.0, h: 0.6667 } })
    @image.update!(crops: { 'banner' => nil })

    assert_equal({}, @image.reload.crops)
  end

  test "effective crop prefers the stored crop and converts to pixels" do
    @image.update!(crops: { 'square' => { x: 0.25, y: 0.0, w: 0.5, h: 1.0 } })

    assert_equal({ x: 0.25, y: 0.0, w: 0.5, h: 1.0 }, @image.effective_crop_for(:square))
    assert_equal [500, 0, 1000, 1000], @image.crop_pixels_for(:square)
    assert_equal [250, 0, 1500, 1000], @image.crop_pixels_for(:card), "auto card crop is centred on the focal point"
  end

  test "focal point must be within the image" do
    @image.focal_x = 1.2
    assert_not @image.valid?
  end

  test "Basil commissions share the same framing behaviour" do
    commission = BasilCommission.create!(user: users(:one), entity: characters(:one), prompt: 'x', job_id: 'j', saved_at: Time.current)
    commission.update_columns(width: 1024, height: 1024)

    assert_equal({ x: 0.0, y: 0.3333, w: 1.0, h: 0.3333 }, commission.auto_crop_for(:banner))
  end
end
