require 'test_helper'

class ImageDerivativeServiceTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @user = users(:one)
    @character = characters(:one)
    @character.update!(user: @user)
    @user.update!(upload_bandwidth_kb: 5000)
  end

  teardown do
    @upload&.destroy
  end

  test "a new upload records its dimensions and cuts every shape derivative" do
    @upload = create_upload

    assert_equal 64, @upload.width
    assert_equal 40, @upload.height
    assert @upload.crops_generated_at.present?, "derivatives are cut synchronously on upload"

    ImagePresets.each do |preset|
      path = @upload.src.path(preset.key)
      assert File.exist?(path), "#{preset.key} derivative should exist at #{path}"
      assert path.end_with?('.webp'), "#{preset.key} derivative is WebP"
      geometry = Paperclip::Geometry.from_file(path)
      assert_equal preset.size, [geometry.width.to_i, geometry.height.to_i], "#{preset.key} derivative has the preset size"

      next unless preset.small_size
      small_path = @upload.src.path(preset.small_style)
      assert File.exist?(small_path), "#{preset.small_style} derivative should exist"
      small_geometry = Paperclip::Geometry.from_file(small_path)
      assert_equal preset.small_size, [small_geometry.width.to_i, small_geometry.height.to_i]
    end

    xlarge = @upload.src.path(:xlarge)
    assert File.exist?(xlarge) && xlarge.end_with?('.webp'), 'xlarge WebP is produced on upload'
    assert_equal 'WEBP', `identify -format %m #{xlarge}`.strip
  end

  test "backfill regenerates the framed styles and xlarge" do
    @upload = create_upload
    File.delete(@upload.src.path(:xlarge))

    assert ImageDerivativeService.backfill!(@upload)
    assert File.exist?(@upload.src.path(:xlarge))
  end

  test "changing the framing regenerates derivatives through a job" do
    @upload = create_upload

    assert_enqueued_with(job: GenerateImageCropsJob, args: ['ImageUpload', @upload.id]) do
      @upload.update!(crops: { 'square' => { x: 0.2, y: 0.0, w: 0.625, h: 1.0 } })
    end

    before = File.mtime(@upload.src.path(:square))
    original_name = @upload.src_file_name
    original_path = @upload.src.path(:original)
    sleep 0.05
    assert ImageDerivativeService.generate!(@upload.reload)
    assert File.mtime(@upload.src.path(:square)) >= before
    geometry = Paperclip::Geometry.from_file(@upload.src.path(:square))
    assert_equal [600, 600], [geometry.width.to_i, geometry.height.to_i]

    @upload.reload
    assert_equal original_name, @upload.src_file_name, "regeneration must not rename the file"
    assert File.exist?(original_path), "the original must survive regeneration"
    assert File.exist?(@upload.src.path(:large)), "untouched styles must survive regeneration"
  end

  test "notes and privacy changes do not trigger regeneration" do
    @upload = create_upload

    assert_no_enqueued_jobs(only: GenerateImageCropsJob) do
      @upload.update!(notes: 'A note', privacy: 'private')
    end
  end

  test "presenter exposes preset URLs only once derivatives exist" do
    @upload = create_upload
    image = ContentImage.wrap(@upload)

    assert image.preset_url(:banner).present?
    assert_includes image.preset_url(:banner), '/banner/'

    @upload.update_columns(crops_generated_at: nil)
    assert_nil ContentImage.wrap(@upload.reload).preset_url(:banner)
  end

  test "Basil variants encode the crop and output size" do
    commission = BasilCommission.create!(user: @user, entity: @character, prompt: 'x', job_id: 'j', saved_at: Time.current)
    # Basil attachments normally live in their own S3 bucket; keep the test on local disk.
    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join('test/fixtures/files/gallery_test.png')),
      filename: 'basil.png',
      content_type: 'image/png',
      service_name: 'test'
    )
    commission.image.attach(blob)
    commission.update_columns(width: 64, height: 40)

    variant = ImageDerivativeService.variant_for(commission, :square)
    transformations = variant.variation.transformations

    assert_equal [600, 600], transformations[:resize_to_fill]
    assert transformations[:crop].present?
    assert_equal :webp, transformations[:format]

    small = ImageDerivativeService.variant_for(commission, :square, small: true)
    assert_equal [200, 200], small.variation.transformations[:resize_to_fill]
    assert ContentImage.wrap(commission).preset_url(:square, size: :small).present?

    assert ContentImage.wrap(commission).preset_url(:square).present?
  end

  test "job discards missing records instead of failing" do
    assert_nothing_raised do
      GenerateImageCropsJob.perform_now('ImageUpload', -1)
    end
  end

  private

  def create_upload
    ImageUpload.create!(
      user: @user,
      content_type: 'Character',
      content_id: @character.id,
      privacy: 'public',
      src: Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/files/gallery_test.png'), 'image/png')
    )
  end
end
