require "test_helper"

# Every gallery endpoint should bump the page's updated_at (so it shows as
# recently edited) and, except for reordering, log to the page's changelog.
class GalleryActivityEndpointsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user      = users(:one)
    @character = characters(:one)
    @image     = image_uploads(:regular)
    @character.update_column(:updated_at, 2.days.ago)
    sign_in @user
  end

  def assert_touched
    assert @character.reload.updated_at > 1.minute.ago, "expected the page's updated_at to be bumped"
  end

  def last_event
    ContentChangeEvent.where(content_type: "Character", content_id: @character.id).order(:id).last
  end

  test "uploading an image" do
    @user.update!(upload_bandwidth_kb: 500)
    post image_uploads_path, params: {
      content_type: "Character", content_id: @character.id,
      src: fixture_file_upload("gallery_test.png", "image/png")
    }, headers: { "Accept" => "application/json" }

    assert_response :created
    assert_touched
    assert_equal "image_added", last_event.action
    assert_equal ImageUpload.last.id, last_event.image_snapshot["id"]
  end

  test "editing notes and privacy" do
    patch image_upload_path(@image), params: { image_upload: { notes: "New notes", privacy: "private" } }, as: :json

    assert_response :success
    assert_touched
    assert_equal "image_updated", last_event.action
    assert_equal({ "notes" => [nil, "New notes"], "privacy" => ["public", "private"] }, last_event.field_changes)
  end

  test "deleting an image" do
    delete image_deletion_path(@image), headers: { "Accept" => "application/json" }

    assert_response :success
    assert_touched
    assert_equal "image_removed", last_event.action
    assert_equal @image.id, last_event.image_snapshot["id"]
  end

  test "setting a per-shape cover" do
    post toggle_image_pin_path, params: { image_id: @image.id, image_type: "image_upload", preset: "banner" },
         headers: { "Accept" => "application/json" }

    assert_response :success
    assert_touched
    assert_equal "cover_changed", last_event.action
    assert_equal({ "cover:banner" => [false, true] }, last_event.field_changes)
  end

  test "reordering only touches the page" do
    assert_no_difference -> { ContentChangeEvent.count } do
      post "/api/v1/gallery_images/sort", params: {
        content_type: "Character", content_id: @character.id,
        images: [{ id: @image.id, type: "image_upload", position: 2 }]
      }, as: :json
    end
    assert_response :success
    assert_touched
  end

  test "saving a Basil image to the page" do
    commission = BasilCommission.create!(user: @user, entity: @character, prompt: "x", job_id: "job-1")

    post basil_save_path(commission), headers: { "Accept" => "application/json" }

    assert_response :success
    assert_touched
    assert_equal "image_added", last_event.action
    assert_equal "BasilCommission", last_event.image_snapshot["type"]

    # Saving again is a no-op for the changelog.
    assert_no_difference -> { ContentChangeEvent.count } do
      post basil_save_path(commission), headers: { "Accept" => "application/json" }
    end
  end
end
