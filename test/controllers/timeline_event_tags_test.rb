require 'test_helper'

# Covers the tag endpoints on TimelineEventsController (add_tag / remove_tag),
# which the timeline editor's inspector panel uses to tag individual events.
class TimelineEventTagsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @owner = users(:one)
    @other = users(:two)

    @timeline = Timeline.create!(name: "Test Timeline", user: @owner)
    @event = @timeline.timeline_events.first
  end

  def add_tag(tag_name)
    post add_tag_timeline_event_path(@event),
         params: { tag_name: tag_name },
         as: :json
  end

  def remove_tag(tag_name)
    delete remove_tag_timeline_event_path(@event, tag_name: tag_name)
  end

  test "owner can add a tag and it persists" do
    sign_in @owner

    add_tag("Foreshadowing")

    assert_response :success
    assert_equal ["Foreshadowing"], @event.reload.page_tags.pluck(:tag)
  end

  test "adding a duplicate tag is an idempotent success, not an error" do
    # The editor adds tags optimistically and removes them from the UI when the
    # server reports failure, so a duplicate must not be treated as an error.
    sign_in @owner
    @event.page_tags.create!(tag: "Foreshadowing", slug: "foreshadowing", user: @owner)

    add_tag("Foreshadowing")

    assert_response :success
    assert_equal 1, @event.reload.page_tags.count
  end

  test "owner can remove a tag" do
    sign_in @owner
    @event.page_tags.create!(tag: "Foreshadowing", slug: "foreshadowing", user: @owner)

    remove_tag("Foreshadowing")

    assert_response :success
    assert_empty @event.reload.page_tags
  end

  test "tags with spaces survive the URL round-trip on removal" do
    sign_in @owner
    @event.page_tags.create!(tag: "Character Development", slug: "character-development", user: @owner)

    delete remove_tag_timeline_event_path(@event, tag_name: "Character Development")

    assert_response :success
    assert_empty @event.reload.page_tags
  end

  test "tags containing a period survive the URL round-trip on removal" do
    sign_in @owner
    @event.page_tags.create!(tag: "v1.0", slug: "v10", user: @owner)

    delete remove_tag_timeline_event_path(@event, tag_name: "v1.0")

    assert_response :success
    assert_empty @event.reload.page_tags
  end

  test "non-owner cannot add a tag" do
    sign_in @other

    add_tag("Sabotage")

    assert_response :forbidden
    assert_empty @event.reload.page_tags
  end
end
