# Records what writers do in a page's image gallery.
#
#   GalleryActivity.touch!(content)
#   GalleryActivity.record!(content, user: current_user, action: :image_added, image: upload)
#   GalleryActivity.record!(content, user: current_user, action: :image_updated, image: upload,
#                           changes: { 'notes' => ['old', 'new'] })
#
# touch! bumps the page's updated_at so it shows up as recently edited (used
# on its own for reorders). record! also writes a ContentChangeEvent against
# the page so the change appears in its changelog.
#
# Edits and cover changes to the same image by the same user within
# COALESCE_WINDOW are merged into one event, keeping the earliest "before" and
# the latest "after"; an event whose changes cancel out is removed.
#
# Failures are logged, never raised: a changelog hiccup shouldn't lose the
# writer's actual change.
class GalleryActivity
  ACTIONS           = ContentChangeEvent::IMAGE_ACTIONS
  COALESCED_ACTIONS = %w(image_updated cover_changed).freeze
  COALESCE_WINDOW   = 10.minutes
  IMAGE_KEY         = ContentChangeEvent::IMAGE_KEY

  def self.touch!(content)
    content&.touch
  rescue StandardError => e
    Rails.logger.warn("GalleryActivity.touch! failed: #{e.class}: #{e.message}")
    nil
  end

  # The changelog-worthy part of an image's last save: notes and privacy as
  # before/after pairs, and any crop or focal-point change as "framing".
  def self.changes_from(image)
    saved = image.saved_changes
    changes = {}
    changes['notes']   = saved['notes'] if saved.key?('notes') && saved['notes'].any?(&:present?)
    changes['privacy'] = saved['privacy'] if saved.key?('privacy')
    changes['framing'] = [nil, 'adjusted'] if (saved.keys & %w(crops focal_x focal_y)).any?
    changes
  end

  def self.record!(content, user:, action:, image:, changes: {})
    new(content, user: user, action: action, image: image, changes: changes).record!
  end

  def initialize(content, user:, action:, image:, changes: {})
    @content = content
    @user    = user
    @action  = action.to_s
    @image   = image.is_a?(ContentImage) ? image.record : image
    @changes = changes.to_h.stringify_keys.reject { |_, (before, after)| before == after }
    raise ArgumentError, "unknown gallery action: #{@action}" unless ACTIONS.include?(@action)
  end

  def record!
    return if @content.nil?

    self.class.touch!(@content)
    return if coalesced? && @changes.empty?

    existing = coalesced? ? recent_event : nil
    existing ? merge_into(existing) : create_event
  rescue StandardError => e
    Rails.logger.warn("GalleryActivity.record! failed: #{e.class}: #{e.message}")
    nil
  end

  private

  def coalesced?
    COALESCED_ACTIONS.include?(@action)
  end

  def create_event
    ContentChangeEvent.create!(
      user:           @user,
      content_type:   @content.class.name,
      content_id:     @content.id,
      action:         @action,
      changed_fields: @changes.merge(IMAGE_KEY => snapshot)
    )
  end

  def merge_into(event)
    fields = event.changed_fields.except(IMAGE_KEY)
    @changes.each do |key, (before, after)|
      fields[key] = [fields.key?(key) ? fields[key].first : before, after]
    end
    fields.reject! { |_, (before, after)| before == after }

    if fields.empty?
      event.destroy
    else
      event.update!(changed_fields: fields.merge(IMAGE_KEY => snapshot))
    end
    event
  end

  def recent_event
    return nil if @user.nil?

    ContentChangeEvent
      .where(user_id: @user.id, content_type: @content.class.name, content_id: @content.id, action: @action)
      .where('updated_at > ?', COALESCE_WINDOW.ago)
      .order(id: :desc)
      .limit(20)
      .detect { |event| event.image_snapshot['type'] == @image.class.name && event.image_snapshot['id'] == @image.id }
  end

  def snapshot
    {
      'id'      => @image.id,
      'type'    => @image.class.name,
      'privacy' => ContentImage.wrap(@image).privacy
    }
  end
end
