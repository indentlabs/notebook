# Lets one image be the cover for specific display shapes.
#
#   image.cover_for            # => ["banner"]
#   image.cover_for?(:banner)  # => true
#
# `pinned` is still the cover for every shape without a specific choice; see
# HasImageUploads#cover_image for the resolution order.
module HasCoverRoles
  extend ActiveSupport::Concern

  included do
    attribute :cover_for, :json, default: -> { [] }
  end

  def cover_for
    value = super
    value = (JSON.parse(value) rescue nil) if value.is_a?(String)
    Array(value).map(&:to_s).select { |key| ImagePresets.valid?(key) }
  end

  def cover_for=(value)
    value = (JSON.parse(value) rescue []) if value.is_a?(String)
    super(Array(value).map(&:to_s).uniq.select { |key| ImagePresets.valid?(key) })
  end

  def cover_for?(preset)
    cover_for.include?(preset.to_s)
  end
end
