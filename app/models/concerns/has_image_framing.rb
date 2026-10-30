# Per-image framing: a focal point plus optional crop rectangles per
# display shape (ImagePresets). Included by ImageUpload and BasilCommission.
#
# Crops are stored normalised to the original image:
#   { "banner" => { "x" => 0.12, "y" => 0.0, "w" => 0.76, "h" => 0.38 } }
# where every value is a fraction of the original width or height.
module HasImageFraming
  extend ActiveSupport::Concern

  # How far a stored crop's aspect ratio may drift from the preset's, to
  # absorb rounding from the editor. 2% is invisible at any display size.
  ASPECT_TOLERANCE = 0.02

  included do
    # Declare the JSON type explicitly so SQLite (development/test) casts
    # the column the same way Postgres does in production.
    attribute :crops, :json, default: -> { {} }

    validates :focal_x, :focal_y, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
    validate :crops_are_well_formed
  end

  # Assign crops from user input. Unknown presets and malformed entries are
  # dropped; numbers are clamped to 0..1 and rounded so they compare cleanly.
  def crops=(value)
    cleaned = {}

    (value.respond_to?(:to_unsafe_h) ? value.to_unsafe_h : value.to_h).each do |key, rect|
      next unless ImagePresets.valid?(key)
      next if rect.blank?

      rect = rect.respond_to?(:to_unsafe_h) ? rect.to_unsafe_h : rect.to_h
      numbers = %w[x y w h].map { |axis| rect[axis] || rect[axis.to_sym] }
      next if numbers.any?(&:nil?)

      x, y, w, h = numbers.map { |n| Float(n) rescue nil }
      next if [x, y, w, h].any?(&:nil?)

      cleaned[key.to_s] = {
        'x' => x.clamp(0.0, 1.0).round(4),
        'y' => y.clamp(0.0, 1.0).round(4),
        'w' => w.clamp(0.0, 1.0).round(4),
        'h' => h.clamp(0.0, 1.0).round(4)
      }
    end

    super(cleaned)
  end

  # Always a Hash, whatever the database adapter hands back.
  def crops
    value = super
    value = (JSON.parse(value) rescue nil) if value.is_a?(String)
    value.is_a?(Hash) ? value : {}
  end

  # The stored crop for +preset+ as a symbol-keyed hash, or nil.
  def crop_for(preset)
    rect = (crops || {})[preset.to_s]
    return nil if rect.blank?

    { x: rect['x'].to_f, y: rect['y'].to_f, w: rect['w'].to_f, h: rect['h'].to_f }
  end

  def custom_crop?(preset)
    crop_for(preset).present?
  end

  def any_custom_crops?
    ImagePresets.keys.any? { |key| custom_crop?(key) }
  end

  def focal_point
    [focal_x.nil? ? 0.5 : focal_x.to_f, focal_y.nil? ? 0.5 : focal_y.to_f]
  end

  # CSS object-position that keeps the focal point in view for any box.
  def object_position_css
    fx, fy = focal_point
    "#{(fx * 100).round(1)}% #{(fy * 100).round(1)}%"
  end

  # The largest rectangle of the preset's shape that fits inside the
  # image, centred on the focal point (and shifted to stay inside).
  # Returns nil when the image dimensions are unknown.
  def auto_crop_for(preset)
    preset = ImagePresets[preset]
    return nil if preset.nil? || width.to_i <= 0 || height.to_i <= 0

    HasImageFraming.auto_rect(width, height, preset.aspect, *focal_point)
  end

  # The largest rectangle with the given aspect that fits inside an image of
  # +width+ x +height+, centred on the focal point (fractions) and shifted to
  # stay inside. Returns normalised { x:, y:, w:, h: }.
  def self.auto_rect(width, height, aspect, focal_x = 0.5, focal_y = 0.5)
    image_aspect = width.to_f / height
    if image_aspect >= aspect
      h = 1.0
      w = aspect / image_aspect
    else
      w = 1.0
      h = image_aspect / aspect
    end

    x = (focal_x.to_f - w / 2).clamp(0.0, 1.0 - w)
    y = (focal_y.to_f - h / 2).clamp(0.0, 1.0 - h)

    { x: x.round(4), y: y.round(4), w: w.round(4), h: h.round(4) }
  end

  # The crop to render for +preset+: the stored one, else the automatic one.
  def effective_crop_for(preset)
    crop_for(preset) || auto_crop_for(preset)
  end

  # Pixel rectangle [x, y, w, h] for +preset+ against the original image, or
  # nil when there is nothing to crop with.
  def crop_pixels_for(preset)
    rect = effective_crop_for(preset)
    return nil if rect.nil? || width.to_i <= 0 || height.to_i <= 0

    [
      (rect[:x] * width).round,
      (rect[:y] * height).round,
      [(rect[:w] * width).round, 1].max,
      [(rect[:h] * height).round, 1].max
    ]
  end

  def framing_changed?
    saved_change_to_crops? || saved_change_to_focal_x? || saved_change_to_focal_y?
  end

  private

  def crops_are_well_formed
    (crops || {}).each do |key, rect|
      preset = ImagePresets[key]
      if preset.nil?
        errors.add(:crops, "includes an unknown shape: #{key}")
        next
      end

      x, y, w, h = %w[x y w h].map { |axis| rect[axis].to_f }

      if w <= 0 || h <= 0
        errors.add(:crops, "#{preset.label} crop has no size")
        next
      end

      if x + w > 1.0001 || y + h > 1.0001
        errors.add(:crops, "#{preset.label} crop extends outside the image")
        next
      end

      next if width.to_i <= 0 || height.to_i <= 0

      actual_aspect = (w * width) / (h * height)
      drift = (actual_aspect - preset.aspect).abs / preset.aspect
      if drift > ASPECT_TOLERANCE
        errors.add(:crops, "#{preset.label} crop must be #{preset.ratio_label}")
      end
    end
  end
end
