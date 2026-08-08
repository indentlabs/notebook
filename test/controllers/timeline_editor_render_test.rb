require 'test_helper'

# Regression coverage for "changes made in the timeline editor disappear on
# refresh": whatever the tag/reorder endpoints persist must actually be
# rendered back by the edit page.
class TimelineEditorRenderTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @owner = users(:one)
    @timeline = Timeline.create!(name: "Render Test Timeline", user: @owner)
    @event = @timeline.timeline_events.first
    sign_in @owner
  end

  test "tags added through the endpoint are rendered on the edit page" do
    post add_tag_timeline_event_path(@event), params: { tag_name: "Foreshadowing" }, as: :json
    assert_response :success

    get edit_timeline_path(@timeline)
    assert_response :success
    assert_includes response.body, "Foreshadowing"
    assert_select "#event-tags-#{@event.id} span", text: /Foreshadowing/
  end

  test "event order persisted through the reorder endpoint is rendered on the edit page" do
    2.times { |i| @timeline.timeline_events.create!(title: "Event #{i}") }
    ids = @timeline.timeline_events.reload.map(&:id)
    desired = ids.reverse

    patch reorder_timeline_events_internal_path,
          params: { timeline_id: @timeline.id, ordered_ids: desired },
          as: :json
    assert_response :success

    get edit_timeline_path(@timeline)
    assert_response :success

    rendered_order = response.body.scan(/data-event-id="(\d+)"/).flatten.map(&:to_i).uniq
    assert_equal desired, rendered_order & desired,
                 "Edit page should render events in their persisted order"
  end
end
