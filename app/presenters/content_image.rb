# Wraps either an ImageUpload (Paperclip, user-uploaded) or a saved
# BasilCommission (ActiveStorage, AI-generated) so that views, JSON responses
# and helpers can treat every gallery image the same way.
#
#   image = ContentImage.wrap(record)
#   image.url(:large)        # => URL of a size-limited derivative
#   image.cover?             # => true when this image is the page's cover
#   image.update_path        # => PATCH endpoint for notes / privacy / crops
#
# Use ContentImage.gallery_for(content, viewer:) to get every image for a
# page in gallery order, filtered by what the viewer is allowed to see.
class ContentImage
  include Rails.application.routes.url_helpers

  # Longest-edge limits for the named sizes shared by both image kinds.
  # Paperclip already defines these styles on ImageUpload#src; for Basil
  # images we produce equivalent ActiveStorage variants on demand.
  SIZE_LIMITS = {
    thumb:  [100, 100],
    small:  [190, 190],
    medium: [300, 300],
    large:  [600, 600],
    hero:   [800, 800]
  }.freeze

  attr_reader :record

  def self.wrap(record)
    record.is_a?(ContentImage) ? record : new(record)
  end

  # Every image attached to +content+, in gallery order. Private uploads are
  # only included when +viewer+ can manage the page's images.
  def self.gallery_for(content, viewer: nil)
    uploads = content.respond_to?(:image_uploads) ? content.image_uploads.ordered.to_a : []
    unless ContentImageAuthorization.can_manage?(viewer, content)
      uploads = uploads.select { |upload| upload.privacy == 'public' }
    end

    basil = if content.respond_to?(:basil_commissions)
      content.basil_commissions.where.not(saved_at: nil).ordered.to_a
    else
      []
    end

    (uploads + basil).map { |record| new(record) }.sort_by(&:sort_key)
  end

  # Finds a page that can hold gallery images from a polymorphic type/id pair
  # sent by the client. Returns nil for unknown or non-image-bearing classes.
  def self.resolve_content(type, id)
    klass = type.to_s.safe_constantize
    return nil unless klass.is_a?(Class) && klass < ApplicationRecord && klass.include?(HasImageUploads)

    klass.find_by(id: id)
  end

  def initialize(record)
    @record = record
  end

  def upload?
    record.is_a?(ImageUpload)
  end

  def basil?
    record.is_a?(BasilCommission)
  end

  # 'upload' or 'basil'; stable identifier used in DOM ids and JSON.
  def kind
    upload? ? 'upload' : 'basil'
  end

  # The value the existing pin/sort endpoints expect in +image_type+.
  def type_param
    upload? ? 'image_upload' : 'basil_commission'
  end

  # The strong-params key the update endpoints expect.
  def param_key
    upload? ? 'image_upload' : 'basil_commission'
  end

  def id
    record.id
  end

  def dom_id
    "#{kind}-#{id}"
  end

  def content
    upload? ? record.content : record.entity
  end

  def pinned?
    record.pinned == true
  end
  alias cover? pinned?

  def notes
    record.notes
  end

  def position
    record.position
  end

  def privacy
    upload? ? (record.privacy.presence || 'public') : 'public'
  end

  def public?
    privacy == 'public'
  end

  # Only uploads carry a privacy setting today.
  def supports_privacy?
    upload?
  end

  def created_at
    upload? ? record.created_at : (record.saved_at || record.created_at)
  end

  def source_label
    upload? ? 'Uploaded' : 'Generated with Basil'
  end

  def filename
    if upload?
      record.src_file_name
    elsif record.image.attached?
      record.image.filename.to_s
    end
  end

  def byte_size
    if upload?
      record.src_file_size
    elsif record.image.attached?
      record.image.byte_size
    end
  end

  def width
    record.try(:width)
  end

  def height
    record.try(:height)
  end

  def attached?
    upload? ? record.src_file_name.present? : record.image.attached?
  end

  # URL for a size-limited derivative (see SIZE_LIMITS), or nil when the
  # record has no file.
  def url(size = :medium)
    return nil unless attached?

    if upload?
      url = record.src(size).to_s
      url.include?('missing.png') ? nil : url
    else
      limit = SIZE_LIMITS[size.to_sym]
      if limit && record.image.variable?
        rails_representation_path(record.image.variant(resize_to_limit: limit), only_path: true)
      else
        original_url
      end
    end
  end

  def original_url
    return nil unless attached?

    if upload?
      record.src(:original).to_s
    else
      rails_blob_path(record.image, disposition: :inline, only_path: true)
    end
  end

  def download_url
    return nil unless attached?

    if upload?
      original_url
    else
      rails_blob_path(record.image, disposition: :attachment, only_path: true)
    end
  end

  def update_path
    upload? ? image_upload_path(id) : basil_commission_update_path(id)
  end

  def delete_path
    upload? ? image_deletion_path(id) : basil_delete_path(id)
  end

  def pin_path
    toggle_image_pin_path(image_type: type_param, image_id: id)
  end

  def sort_key
    [position || 999_999, created_at || Time.current, dom_id]
  end

  def as_json(*)
    {
      id:         id,
      kind:       kind,
      type:       type_param,
      dom_id:     dom_id,
      pinned:     pinned?,
      notes:      notes,
      position:   position,
      privacy:    privacy,
      byte_size:  byte_size,
      width:      width,
      height:     height,
      urls: {
        thumb:    url(:thumb),
        medium:   url(:medium),
        large:    url(:large),
        original: original_url
      }
    }
  end
end
