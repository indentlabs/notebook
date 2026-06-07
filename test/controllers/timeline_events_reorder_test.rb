require 'test_helper'

# Covers the internal reorder endpoint (TimelineEventsController#reorder), which
# both drag-and-drop and the move menu use. The endpoint receives the full,
# authoritative ordering of a timeline's events and rewrites every position as a
# clean 1..N sequence in one transaction, so it is idempotent and immune to the
# races that previously left events with duplicate/garbled positions.
class TimelineEventsReorderTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @owner = users(:one)
    @other = users(:two)

    @timeline = Timeline.create!(name: "Test Timeline", user: @owner)
    # Timeline#initialize_first_event already created one event on create; add a
    # few more so we have a meaningful order to shuffle.
    3.times { |i| @timeline.timeline_events.create!(title: "Event #{i}") }

    @event_ids = ordered_event_ids
    assert_equal 4, @event_ids.length, "Setup expects four events to reorder"
  end

  # Event ids in their stored (position-ascending) order.
  def ordered_event_ids
    @timeline.timeline_events.reload.map(&:id)
  end

  def stored_positions
    @timeline.timeline_events.reload.map(&:position)
  end

  def reorder(ordered_ids)
    patch reorder_timeline_events_internal_path,
          params: { timeline_id: @timeline.id, ordered_ids: ordered_ids },
          as: :json
  end

  test "rewrites positions to match the submitted order as a clean 1..N sequence" do
    sign_in @owner
    desired = @event_ids.reverse

    reorder(desired)

    assert_response :success
    assert_equal desired, ordered_event_ids
    assert_equal (1..desired.length).to_a, stored_positions
  end

  test "is idempotent and normalizes duplicate/garbled positions" do
    sign_in @owner
    # Simulate the corruption this endpoint is meant to heal: force every event
    # to share the same position.
    @timeline.timeline_events.each { |event| event.update_column(:position, 1) }

    desired = @event_ids
    reorder(desired)
    reorder(desired) # run twice to prove a repeated call changes nothing

    assert_response :success
    assert_equal desired, ordered_event_ids
    assert_equal (1..desired.length).to_a, stored_positions
  end

  test "appends events omitted from the payload after the provided ones" do
    sign_in @owner
    moved = @event_ids.last

    # Mention only the last event; the other three are omitted from the payload.
    reorder([moved])

    assert_response :success
    result = ordered_event_ids

    assert_equal moved, result.first, "Provided event should be placed first"
    assert_equal @event_ids.length, result.length, "No events should be dropped"
    assert_equal (1..@event_ids.length).to_a, stored_positions, "Positions stay a unique 1..N"
    assert_equal (@event_ids - [moved]), result[1..], "Omitted events keep their relative order"
  end

  test "rejects reordering a timeline the user does not own" do
    sign_in @other
    original = ordered_event_ids

    reorder(@event_ids.reverse)

    assert_response :not_found
    assert_equal original, ordered_event_ids, "Order must be unchanged"
  end

  test "rejects reordering when not signed in" do
    original = ordered_event_ids

    reorder(@event_ids.reverse)

    assert_response :forbidden
    assert_equal original, ordered_event_ids, "Order must be unchanged"
  end
end
