# Paperclip processor that crops to the rectangle a writer chose in the
# gallery editor (or the automatic focal-point crop) before resizing to the
# preset's output size.
#
# Used by ImageUpload's banner / card / square styles:
#
#   styles: { banner: { geometry: '1500x500#', processors: [:cropper], preset: :banner } }
#
# The crop rectangle is stored normalised (fractions of the oriented image),
# so it is converted to pixels against the file actually being processed
# rather than against whatever dimensions happen to be in the database.
module Paperclip
  class Cropper < Thumbnail
    def transformation_command
      rect = crop_rectangle
      return super if rect.nil?

      x, y, w, h = rect
      trans = []
      trans << "-coalesce" if animated?
      trans << "-auto-orient" if auto_orient
      trans << "-crop" << %["#{w}x#{h}+#{x}+#{y}"] << "+repage"
      trans << "-resize" << %["#{@target_geometry.width.to_i}x#{@target_geometry.height.to_i}!"]
      trans
    end

    private

    def crop_rectangle
      preset_key = @options[:preset]
      preset = ImagePresets[preset_key] if preset_key
      return nil if preset.nil?

      record = @attachment.instance
      width  = @current_geometry.width.to_i
      height = @current_geometry.height.to_i
      return nil if width <= 0 || height <= 0

      normalised = record.respond_to?(:crop_for) ? record.crop_for(preset.key) : nil
      normalised ||= HasImageFraming.auto_rect(width, height, preset.aspect, *(record.try(:focal_point) || [0.5, 0.5]))

      [
        (normalised[:x] * width).round,
        (normalised[:y] * height).round,
        [(normalised[:w] * width).round, 1].max,
        [(normalised[:h] * height).round, 1].max
      ]
    end
  end
end
