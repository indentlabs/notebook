# Chooses which gallery image represents a page.
#
#   ContentCoverService.toggle!(image)                  # cover for everything (the pin)
#   ContentCoverService.toggle!(image, preset: :banner) # cover for one shape only
#
# Only one image per page can hold each role, so turning a role on clears it
# from every other image of the same page. Writes use update_column to avoid
# the callback chains that used to cause lock contention.
class ContentCoverService
  Result = Struct.new(:pinned, :preset, :active, :cover_for, keyword_init: true)

  def self.toggle!(image, preset: nil)
    new(image).toggle!(preset: preset)
  end

  def initialize(image)
    @image   = image
    @content = image.is_a?(ImageUpload) ? image.content : image.entity
  end

  def toggle!(preset: nil)
    raise ArgumentError, 'image has no content' if @content.nil?

    result = if preset.present?
      toggle_role!(preset.to_s)
    else
      toggle_pin!
    end

    @content.touch
    @content.clear_cover_image_cache if @content.respond_to?(:clear_cover_image_cache)
    result
  end

  private

  def toggle_pin!
    turning_on = !(@image.pinned == true)

    if turning_on
      other_uploads.where(pinned: true).update_all(pinned: false)
      other_commissions.where(pinned: true).update_all(pinned: false)
    end

    @image.update_column(:pinned, turning_on)
    Result.new(pinned: turning_on, cover_for: @image.cover_for)
  end

  def toggle_role!(preset)
    raise ArgumentError, "unknown shape: #{preset}" unless ImagePresets.valid?(preset)

    turning_on = !@image.cover_for?(preset)

    if turning_on
      (other_uploads.to_a + other_commissions.to_a).each do |other|
        next unless other.cover_for?(preset)

        other.update_column(:cover_for, other.cover_for - [preset])
      end
    end

    roles = turning_on ? (@image.cover_for + [preset]).uniq : (@image.cover_for - [preset])
    @image.update_column(:cover_for, roles)

    Result.new(pinned: @image.pinned == true, preset: preset, active: turning_on, cover_for: roles)
  end

  def other_uploads
    scope = ImageUpload.where(content_type: @content.class.name, content_id: @content.id)
    @image.is_a?(ImageUpload) ? scope.where.not(id: @image.id) : scope
  end

  def other_commissions
    scope = BasilCommission.where(entity_type: @content.class.name, entity_id: @content.id)
    @image.is_a?(BasilCommission) ? scope.where.not(id: @image.id) : scope
  end
end
