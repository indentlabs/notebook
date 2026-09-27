require "test_helper"

class GalleryActivityTest < ActiveSupport::TestCase
  setup do
    @user      = users(:one)
    @character = characters(:one)
    @image     = image_uploads(:regular)
    @character.update_column(:updated_at, 2.days.ago)
  end

  def events
    ContentChangeEvent.where(content_type: "Character", content_id: @character.id, action: ContentChangeEvent::IMAGE_ACTIONS)
  end

  test "touch! bumps the page without logging anything" do
    assert_no_difference -> { ContentChangeEvent.count } do
      GalleryActivity.touch!(@character)
    end
    assert @character.reload.updated_at > 1.minute.ago
  end

  test "record! touches the page and logs an event with an image snapshot" do
    GalleryActivity.record!(@character, user: @user, action: :image_added, image: @image)

    assert @character.reload.updated_at > 1.minute.ago
    event = events.last
    assert_equal "image_added", event.action
    assert_equal @user, event.user
    assert_equal({ "id" => @image.id, "type" => "ImageUpload", "privacy" => "public" }, event.image_snapshot)
    assert_equal 1, event.change_count
    assert_equal @image, event.image_record
  end

  test "edits to the same image within the window are merged" do
    GalleryActivity.record!(@character, user: @user, action: :image_updated, image: @image, changes: { "notes" => ["", "a"] })
    GalleryActivity.record!(@character, user: @user, action: :image_updated, image: @image, changes: { "notes" => ["a", "ab"] })
    GalleryActivity.record!(@character, user: @user, action: :image_updated, image: @image, changes: { "privacy" => ["public", "private"] })

    assert_equal 1, events.count
    assert_equal({ "notes" => ["", "ab"], "privacy" => ["public", "private"] }, events.last.field_changes)
    assert_equal 2, events.last.change_count
  end

  test "edits outside the window start a new event" do
    GalleryActivity.record!(@character, user: @user, action: :image_updated, image: @image, changes: { "notes" => ["", "a"] })
    events.last.update_column(:updated_at, 11.minutes.ago)
    GalleryActivity.record!(@character, user: @user, action: :image_updated, image: @image, changes: { "notes" => ["a", "b"] })

    assert_equal 2, events.count
  end

  test "edits to a different image are not merged" do
    GalleryActivity.record!(@character, user: @user, action: :image_updated, image: @image, changes: { "notes" => ["", "a"] })
    GalleryActivity.record!(@character, user: @user, action: :image_updated, image: image_uploads(:pinned), changes: { "notes" => ["", "b"] })

    assert_equal 2, events.count
  end

  test "changes that cancel out remove the event" do
    GalleryActivity.record!(@character, user: @user, action: :cover_changed, image: @image, changes: { "cover" => [false, true] })
    GalleryActivity.record!(@character, user: @user, action: :cover_changed, image: @image, changes: { "cover" => [true, false] })

    assert_equal 0, events.count
  end

  test "an update with nothing changelog-worthy only touches the page" do
    assert_no_difference -> { ContentChangeEvent.count } do
      GalleryActivity.record!(@character, user: @user, action: :image_updated, image: @image, changes: {})
    end
    assert @character.reload.updated_at > 1.minute.ago
  end

  test "changes_from picks out notes, privacy and framing" do
    @image.update!(notes: "hello", privacy: "private", focal_x: 0.3)
    assert_equal({ "notes" => [nil, "hello"], "privacy" => ["public", "private"], "framing" => [nil, "adjusted"] },
                 GalleryActivity.changes_from(@image))

    @image.update!(notes: "hello")
    assert_equal({}, GalleryActivity.changes_from(@image))
  end

  test "changelog_events mixes attribute and gallery events" do
    GalleryActivity.record!(@character, user: @user, action: :image_added, image: @image)
    assert_includes @character.changelog_events.map(&:action), "image_added"
  end
end
