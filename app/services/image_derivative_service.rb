# Produces (and locates) the per-shape derivatives of a gallery image.
#
# Uploaded images (Paperclip) get real files per ImagePresets style, cut by
# the Cropper processor. Basil images (ActiveStorage) get variants whose key
# already encodes the crop, so they are generated on first request and only
# pre-warmed here.
#
#   ImageDerivativeService.generate!(image_upload)   # reprocess crop styles
#   ImageDerivativeService.variant_for(commission, :banner)
class ImageDerivativeService
  # Regenerate the crop-shaped derivatives for +record+ from its current
  # framing. Returns true when something was produced.
  def self.generate!(record)
    new(record).generate!
  end

  def self.variant_for(commission, preset)
    new(commission).variant_for(preset)
  end

  def initialize(record)
    @record = record
  end

  def generate!
    case @record
    when ImageUpload        then generate_upload_styles!
    when BasilCommission    then prewarm_variants!
    else false
    end
  end

  # ActiveStorage variant for +preset+, cropped to the record's framing.
  def variant_for(preset)
    preset = ImagePresets[preset]
    return nil if preset.nil? || !@record.image.attached? || !@record.image.variable?

    pixels = @record.crop_pixels_for(preset.key)
    transformations = {}
    if pixels
      x, y, w, h = pixels
      transformations[:crop] = vips? ? [x, y, w, h] : "#{w}x#{h}+#{x}+#{y}"
    end
    transformations[:resize_to_fill] = preset.size

    @record.image.variant(transformations)
  end

  private

  def generate_upload_styles!
    return false unless @record.src_file_name.present?

    attachment = @record.src
    original_cleaner = attachment.options[:filename_cleaner]
    # ImageUpload renames files to a fresh UUID on assignment. Reprocessing
    # re-assigns the attachment, so without this the record would point at a
    # new name while the original stayed under the old one.
    attachment.options[:filename_cleaner] = ->(filename) { filename }

    begin
      attachment.reprocess!(*ImagePresets.keys)
    ensure
      attachment.options[:filename_cleaner] = original_cleaner
    end

    @record.update_columns(crops_generated_at: Time.current)
    true
  end

  def prewarm_variants!
    return false unless @record.image.attached?

    ImagePresets.keys.each do |key|
      variant = variant_for(key)
      variant.processed if variant
    end
    @record.update_columns(crops_generated_at: Time.current)
    true
  end

  def vips?
    ActiveStorage.variant_processor.to_s == 'vips'
  end
end
