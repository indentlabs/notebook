require 'test_helper'

# Who can reach a timeline and its events. Events have their own routes, so they
# need to be just as locked down as the timeline they belong to.
class TimelineAccessTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  SECRET_NAME        = 'SECRETTIMELINE'
  SECRET_DESCRIPTION = 'SECRETDESCRIPTION'
  SECRET_EVENT       = 'SECRETEVENT'

  setup do
    @owner    = users(:one)
    @stranger = users(:two)
    @timeline = Timeline.create!(name: SECRET_NAME, description: SECRET_DESCRIPTION, user: @owner, privacy: 'private')
    @event    = @timeline.timeline_events.first
    @event.update!(title: SECRET_EVENT)
  end

  def assert_no_secrets
    assert_not_includes response.body, SECRET_NAME
    assert_not_includes response.body, SECRET_DESCRIPTION
    assert_not_includes response.body, SECRET_EVENT
  end

  def assert_timeline_shown
    assert_response :success
    assert_includes response.body, SECRET_NAME
    assert_includes response.body, SECRET_EVENT
  end

  def assert_event_unchanged
    assert_equal SECRET_EVENT, @event.reload.title
  end

  def add_contributor(user)
    universe = Universe.create!(name: 'Shared universe', user: @owner, privacy: 'private')
    Contributor.create!(universe: universe, user: user, email: user&.email || 'unclaimed@example.com')
    @timeline.update!(universe: universe)
  end

  test "signed out visitors can't read a private timeline" do
    get timeline_path(@timeline)

    assert_redirected_to root_path
    assert_no_secrets
  end

  test "signed in strangers can't read a private timeline" do
    sign_in @stranger
    get timeline_path(@timeline)

    assert_redirected_to root_path
    assert_no_secrets
  end

  test "an unclaimed contributor invite doesn't open a private timeline to signed out visitors" do
    add_contributor(nil)

    get timeline_path(@timeline)

    assert_redirected_to root_path
    assert_no_secrets
  end

  test "the owner can read their private timeline" do
    sign_in @owner
    get timeline_path(@timeline)

    assert_timeline_shown
  end

  test "anyone can read a public timeline" do
    @timeline.update!(privacy: 'public')

    get timeline_path(@timeline)

    assert_timeline_shown
  end

  test "a universe contributor can read a private timeline" do
    add_contributor(@stranger)
    sign_in @stranger

    get timeline_path(@timeline)

    assert_timeline_shown
  end

  test "strangers can't open the editor" do
    sign_in @stranger
    get edit_timeline_path(@timeline)

    assert_redirected_to root_path
    assert_no_secrets
  end

  test "strangers can't rename a timeline" do
    sign_in @stranger
    patch timeline_path(@timeline), params: { timeline: { name: 'Renamed' } }

    assert_redirected_to root_path
    assert_equal SECRET_NAME, @timeline.reload.name
  end

  test "strangers can't delete a timeline" do
    sign_in @stranger
    delete timeline_path(@timeline)

    assert_redirected_to root_path
    assert Timeline.exists?(@timeline.id)
  end

  test "a universe contributor can edit a timeline but not delete it" do
    add_contributor(@stranger)
    sign_in @stranger

    get edit_timeline_path(@timeline)
    assert_response :success

    patch timeline_path(@timeline), params: { timeline: { name: 'Renamed' } }
    assert_response :success
    assert_equal 'Renamed', @timeline.reload.name

    delete timeline_path(@timeline)
    assert_redirected_to root_path
    assert Timeline.exists?(@timeline.id)
  end

  test "a universe contributor can't delete a timeline through an update" do
    add_contributor(@stranger)
    sign_in @stranger

    patch timeline_path(@timeline), params: { timeline: { name: 'Renamed', deleted_at: Time.current } }

    assert Timeline.exists?(@timeline.id)
  end

  test "the owner can edit and delete their timeline" do
    sign_in @owner

    get edit_timeline_path(@timeline)
    assert_response :success

    patch timeline_path(@timeline), params: { timeline: { name: 'Renamed' } }
    assert_response :success
    assert_equal 'Renamed', @timeline.reload.name

    delete timeline_path(@timeline)
    assert_redirected_to timelines_path
    assert_not Timeline.exists?(@timeline.id)
  end

  test "signed out visitors can't change or delete an event" do
    patch timeline_event_path(@event), params: { timeline_event: { title: 'Changed' } }
    assert_redirected_to new_user_session_path
    assert_event_unchanged

    delete timeline_event_path(@event)
    assert_redirected_to new_user_session_path
    assert TimelineEvent.exists?(@event.id)
  end

  test "strangers can't change or delete an event" do
    sign_in @stranger

    patch timeline_event_path(@event), params: { timeline_event: { title: 'Changed' } }
    assert_response :forbidden
    assert_event_unchanged

    delete timeline_event_path(@event)
    assert_response :forbidden
    assert TimelineEvent.exists?(@event.id)
  end

  test "the owner can change and delete an event" do
    sign_in @owner

    patch timeline_event_path(@event), params: { timeline_event: { title: 'Changed' } }, as: :json
    assert_response :success
    assert_equal 'Changed', @event.reload.title

    delete timeline_event_path(@event)
    assert_redirected_to edit_timeline_path(@timeline)
    assert_not TimelineEvent.exists?(@event.id)
  end

  test "a universe contributor can change, tag and delete an event" do
    add_contributor(@stranger)
    sign_in @stranger

    patch timeline_event_path(@event), params: { timeline_event: { title: 'Changed' } }, as: :json
    assert_response :success
    assert_equal 'Changed', @event.reload.title

    post add_tag_timeline_event_path(@event), params: { tag_name: 'Foreshadowing' }, as: :json
    assert_response :success

    delete timeline_event_path(@event)
    assert_redirected_to edit_timeline_path(@timeline)
  end

  test "an event can't be moved onto someone else's timeline" do
    theirs = Timeline.create!(name: 'Theirs', user: @stranger)
    sign_in @owner

    patch timeline_event_path(@event), params: { timeline_event: { title: 'Changed', timeline_id: theirs.id } }, as: :json

    assert_response :success
    assert_equal @timeline.id, @event.reload.timeline_id
  end

  test "the leftover event pages are gone" do
    [
      -> { get timeline_events_path },
      -> { get new_timeline_event_path },
      -> { get timeline_event_path(@event) },
      -> { get edit_timeline_event_path(@event) }
    ].each do |request|
      assert_raises(ActionController::RoutingError, NameError) { request.call }
    end
  end
end
