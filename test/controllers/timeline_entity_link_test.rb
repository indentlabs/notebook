require 'test_helper'

# A timeline can be more public than the pages linked to its events, so linking
# and the linked page cards must never show a page its viewer couldn't open.
class TimelineEntityLinkTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  SECRET_NAME = 'SECRETLINKEDPAGE'

  setup do
    @owner    = users(:one)
    @stranger = users(:two)

    @timeline = Timeline.create!(name: 'Public timeline', user: @owner, privacy: 'public')
    @event    = @timeline.timeline_events.first
    @secret   = Character.create!(name: SECRET_NAME, user: @stranger, privacy: 'private')
  end

  def link(type, id)
    post "/plan/timeline_events/#{@event.id}/link", params: { entity_type: type, entity_id: id }, as: :json
  end

  test "someone else's private page can't be linked" do
    sign_in @owner

    assert_no_difference 'TimelineEventEntity.count' do
      link('Character', @secret.id)
    end

    assert_response :not_found
    assert_not_includes response.body, SECRET_NAME
  end

  test "only page types can be linked" do
    sign_in @owner

    assert_no_difference 'TimelineEventEntity.count' do
      link('User', @stranger.id)
    end
    assert_response :not_found
  end

  test "your own private pages and other people's public pages can be linked" do
    mine = Character.create!(name: 'My own', user: @owner, privacy: 'private')
    theirs = Character.create!(name: 'Their public one', user: @stranger, privacy: 'public')
    sign_in @owner

    assert_difference 'TimelineEventEntity.count', 2 do
      link('Character', mine.id)
      link('Character', theirs.id)
    end
    assert_response :success
  end

  test "a page linked while public stops showing on the timeline once it goes private" do
    @secret.update!(privacy: 'public')
    @event.timeline_event_entities.create!(entity: @secret)
    @secret.update!(privacy: 'private')

    get timeline_path(@timeline)

    assert_response :success
    assert_not_includes response.body, SECRET_NAME
  end

  test "the owner of a linked page still sees it" do
    @event.timeline_event_entities.create!(entity: @secret)
    sign_in @stranger

    get timeline_path(@timeline)

    assert_includes response.body, SECRET_NAME
  end
end
