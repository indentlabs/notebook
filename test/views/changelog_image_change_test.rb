require "test_helper"

class ChangelogImageChangeTest < ActionView::TestCase
  setup do
    @user      = users(:one)
    @character = characters(:one)
    @image     = image_uploads(:regular)
  end

  def render_event(action, changes = {}, image: @image)
    GalleryActivity.record!(@character, user: @user, action: action, image: image, changes: changes)
    event = ContentChangeEvent.where(content_type: "Character", content_id: @character.id).order(:id).last
    render partial: "content/changelog/image_change", locals: { change_event: event }
  end

  test "describes an upload" do
    render_event(:image_added)
    assert_includes rendered, "Uploaded an image"
  end

  test "describes privacy, framing and notes edits" do
    render_event(:image_updated, { "privacy" => ["public", "private"], "framing" => [nil, "adjusted"], "notes" => ["old", "new"] })
    assert_includes rendered, "Edited an image"
    assert_includes rendered, "Made private"
    assert_includes rendered, "Adjusted the cropping and framing"
    assert_includes rendered, "Previous notes"
  end

  test "describes per-shape cover changes" do
    render_event(:cover_changed, { "cover:banner" => [false, true] })
    assert_includes rendered, "Set as the banner cover"
  end

  test "still renders once the image is gone" do
    render_event(:image_removed)
    @image.delete
    render partial: "content/changelog/image_change",
           locals: { change_event: ContentChangeEvent.order(:id).last }
    assert_includes rendered, "Removed an image"
  end
end
