class ContentChangeEvent < ApplicationRecord
  belongs_to :user

  serialize :changed_fields, Hash

  # Don't show or create ContentChangeEvents for content changes on these attributes
  FIELD_IDS_TO_EXCLUDE = %w(
    id created_at updated_at user user_id
  )

  BLANK_PLACEHOLDER   = ''
  PRIVATE_PLACEHOLDER = '(hidden)'

  # Gallery activity is logged against the page itself (see GalleryActivity),
  # with a snapshot of the image stored under IMAGE_KEY in changed_fields.
  IMAGE_ACTIONS = %w(image_added image_removed image_updated cover_changed).freeze
  IMAGE_KEY     = '_image'

  def content
    content_type.constantize.find_by(id: content_id)
  end
  
  def entity
    content.try(:entity) || content
  end

  def image_event?
    IMAGE_ACTIONS.include?(action)
  end

  def image_snapshot
    image_event? ? (changed_fields[IMAGE_KEY] || {}) : {}
  end

  # The image this event is about, if it still exists.
  def image_record
    klass = { 'ImageUpload' => ImageUpload, 'BasilCommission' => BasilCommission }[image_snapshot['type']]
    klass&.find_by(id: image_snapshot['id'])
  end

  def field_changes
    changed_fields.except(IMAGE_KEY)
  end

  # How many things this event changed, for "N changes" counts and stats.
  def change_count
    image_event? ? [field_changes.size, 1].max : changed_fields.keys.length
  end
end
