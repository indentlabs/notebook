require 'test_helper'

# A private page's name can give away what's in it, so nothing outside the page itself
# should show it to people who can't read the page.
class PrivatePageNamesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  SECRET_NAME        = 'SECRETCHARACTER'
  SECRET_DESCRIPTION = 'SECRETDESCRIPTION'

  setup do
    @author   = users(:one)
    @stranger = users(:two)
    @page     = Character.create!(user: @author, name: SECRET_NAME, privacy: 'private')
    # Fixture shares point at nothing, which the feed can't render
    ContentPageShare.update_all(deleted_at: Time.current)
  end

  def assert_no_secrets
    assert_not_includes response.body, SECRET_NAME
    assert_not_includes response.body, SECRET_DESCRIPTION
  end

  def public_page_referenced_by(page)
    Location.create!(user: @author, name: 'Public location', privacy: 'public').tap do |location|
      PageReference.new(referencing_page: page, referenced_page: location).save!(validate: false)
    end
  end

  test "the name lookup shows a label to people who can't read a page" do
    get "/api/internal/Character/#{@page.id}/name"
    assert_equal 'Private character', response.body

    sign_in @stranger
    get "/api/internal/Character/#{@page.id}/name"
    assert_equal 'Private character', response.body
  end

  test "the name lookup labels other page types the same way" do
    document = Document.create!(user: @author, title: SECRET_NAME, body: 'text', privacy: 'private')
    timeline = Timeline.create!(user: @author, name: SECRET_NAME, privacy: 'private')

    get "/api/internal/Document/#{document.id}/name"
    assert_equal 'Private document', response.body

    get "/api/internal/Timeline/#{timeline.id}/name"
    assert_equal 'Private timeline', response.body
  end

  test "the name lookup shows the name to people who can read the page" do
    sign_in @author
    get "/api/internal/Character/#{@page.id}/name"
    assert_equal SECRET_NAME, response.body

    sign_out @author
    @page.update!(privacy: 'public')
    get "/api/internal/Character/#{@page.id}/name"
    assert_equal SECRET_NAME, response.body
  end

  test "the name lookup says so when a page doesn't exist" do
    get "/api/internal/Character/0/name"
    assert_equal 'Page not found', response.body
  end

  test "content links show a label to people who can't read the page" do
    token = "[[Character-#{@page.id}]]"

    [@stranger, User.new].each do |viewer|
      linked = ContentFormatterService.show(text: token.dup, viewing_user: viewer)
      assert_includes linked, 'Private character'
      assert_not_includes linked, SECRET_NAME
      assert_not_includes linked, "/characters/#{@page.id}"

      plain = ContentFormatterService.plaintext_show(text: token.dup, viewing_user: viewer)
      assert_includes plain, 'Private character'
      assert_not_includes plain, SECRET_NAME
    end
  end

  test "content links still show the name to people who can read the page" do
    token = "[[Character-#{@page.id}]]"

    linked = ContentFormatterService.show(text: token.dup, viewing_user: @author)
    assert_includes linked, SECRET_NAME
    assert_includes linked, "/characters/#{@page.id}"

    assert_includes ContentFormatterService.plaintext_show(text: token.dup, viewing_user: @author), SECRET_NAME
  end

  test "the stream hides the preview of a shared page that has gone private" do
    ContentPageShare.create!(user: @author, content_page: @page, message: 'hi', shared_at: DateTime.current)
    sign_in @stranger

    get stream_world_path

    assert_response :success
    assert_no_secrets
    assert_includes response.body, 'This page is no longer public'
  end

  test "the stream still previews a shared public page" do
    @page.update!(privacy: 'public')
    ContentPageShare.create!(user: @author, content_page: @page, message: 'hi', shared_at: DateTime.current)
    sign_in @stranger

    get stream_world_path

    assert_includes response.body, SECRET_NAME
  end

  test "the stream can still render a share of a page collection" do
    collection = PageCollection.create!(user: @author, title: 'Public collection', privacy: 'public', page_types: ['Character'])
    ContentPageShare.create!(user: @author, content_page: collection, message: 'hi', shared_at: DateTime.current)
    sign_in @stranger

    get stream_world_path

    assert_response :success
    assert_includes response.body, 'Public collection'
  end

  test "a share page hides the preview of a page that has gone private" do
    share = ContentPageShare.create!(user: @author, content_page: @page, message: 'hi', shared_at: DateTime.current)

    get user_content_page_share_path(@author, share)

    assert_response :success
    assert_no_secrets
  end

  test "a share page's more from this user box only lists public pages" do
    Location.create!(user: @author, name: 'Public location', privacy: 'public')
    other_page = Character.create!(user: @author, name: 'Public character', privacy: 'public')
    share = ContentPageShare.create!(user: @author, content_page: other_page, message: 'hi', shared_at: DateTime.current)

    get user_content_page_share_path(@author, share)

    assert_response :success
    assert_no_secrets
    assert_includes response.body, 'Public location'
  end

  test "the references page is only for people who can read the page" do
    sign_in @stranger

    get references_character_path(@page)

    assert_redirected_to root_path
    assert_no_secrets
  end

  test "the references page still works for the page's author" do
    sign_in @author

    get references_character_path(@page)

    assert_response :success
    assert_includes response.body, SECRET_NAME
  end

  test "the references page doesn't name private pages that mention this one" do
    location = public_page_referenced_by(@page)
    sign_in @stranger

    get references_location_path(location)

    assert_response :success
    assert_no_secrets
  end

  test "the references page still names readable pages that mention this one" do
    location = public_page_referenced_by(@page)
    sign_in @author

    get references_location_path(location)

    assert_response :success
    assert_includes response.body, SECRET_NAME
  end

  test "the associations tab doesn't name private pages that mention this one" do
    location = public_page_referenced_by(@page)

    get location_path(location)

    assert_response :success
    assert_no_secrets
    assert_not_includes response.body, 'Referenced By'
  end

  test "the associations tab still names readable pages that mention this one" do
    location = public_page_referenced_by(@page)
    sign_in @author

    get location_path(location)

    assert_includes response.body, SECRET_NAME
    assert_includes response.body, 'Referenced By'
  end

  test "the timelines tab doesn't name private timelines" do
    location = Location.create!(user: @author, name: 'Public location', privacy: 'public')
    linking  = Timeline.create!(user: @author, name: SECRET_NAME, privacy: 'private')
    PageReference.new(referencing_page: linking, referenced_page: location).save!(validate: false)
    mentioning = Timeline.create!(user: @author, name: SECRET_DESCRIPTION, privacy: 'private')
    TimelineEventEntity.create!(timeline_event: mentioning.timeline_events.first, entity: location)

    get location_path(location)

    assert_response :success
    assert_no_secrets
  end

  test "the timelines tab still names readable timelines" do
    location = Location.create!(user: @author, name: 'Public location', privacy: 'public')
    linking  = Timeline.create!(user: @author, name: SECRET_NAME, privacy: 'public')
    PageReference.new(referencing_page: linking, referenced_page: location).save!(validate: false)
    mentioning = Timeline.create!(user: @author, name: SECRET_DESCRIPTION, privacy: 'public')
    TimelineEventEntity.create!(timeline_event: mentioning.timeline_events.first, entity: location)

    get location_path(location)

    assert_includes response.body, SECRET_NAME
    assert_includes response.body, SECRET_DESCRIPTION
  end
end
