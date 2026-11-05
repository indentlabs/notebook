require 'test_helper'

# Walks every surface that can show a worldbuilding page, with a password protected one
# inside a public universe. Nothing here has entered the password, so all of them should
# treat it like a private page, even though the public universe would normally open it up.
class PagePasswordPrivacyTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  PASSWORD    = 'correct horse'
  SECRET_NAME = 'SECRETPAGENAME'

  setup do
    @author   = users(:one)
    @stranger = users(:two)
    @universe = Universe.create!(user: @author, name: 'Open Universe', privacy: 'public')
    @page     = Character.create!(user: @author, universe: @universe, name: SECRET_NAME, privacy: 'private')
    @page.protect_with_password(PASSWORD)
    # Fixture shares point at nothing, which the feed can't render
    ContentPageShare.update_all(deleted_at: Time.current)
  end

  def assert_no_secrets
    assert_not_includes response.body, SECRET_NAME
  end

  def assert_shown
    assert_includes response.body, SECRET_NAME
  end

  def as_each_outsider
    [nil, @stranger].each do |viewer|
      sign_in viewer if viewer
      yield viewer
      sign_out viewer if viewer
    end
  end

  test "the password outranks a public universe" do
    assert_not User.new.can_read?(@page)
    assert_not @stranger.can_read?(@page)
    assert_not @page.public_content?
    assert_not PermissionService.content_is_publicly_visible?(content: @page)
    assert_not_includes Character.is_public, @page
  end

  test "other pages in the public universe still come along with it" do
    private_neighbour = Character.create!(user: @author, universe: @universe, name: 'Neighbour', privacy: 'private')
    no_privacy = Character.create!(user: @author, universe: @universe, name: 'No privacy value')
    no_privacy.update_column(:privacy, nil)

    assert_includes Character.is_public, private_neighbour
    assert_includes Character.is_public, no_privacy
    assert User.new.can_read?(private_neighbour)
  end

  test "the owner, universe members and site admins skip the password" do
    universe = Universe.create!(user: @stranger, name: 'Their Universe', privacy: 'public')
    contributor = User.create!(name: 'Contributor', email: 'contributor@example.com', password: 'password123')
    Contributor.create!(universe: universe, user: contributor)
    admin = User.create!(name: 'Admin', email: 'admin@example.com', password: 'password123', site_administrator: true)
    outsider = User.create!(name: 'Outsider', email: 'outsider@example.com', password: 'password123')
    @page.update_column(:universe_id, universe.id)
    @page.reload

    assert @author.can_read?(@page)
    assert @stranger.can_read?(@page), "The universe's owner should get in"
    assert contributor.can_read?(@page), "The universe's contributors should get in"
    assert admin.can_read?(@page)
    assert_not outsider.can_read?(@page)
  end

  test "an unclaimed contributor invite doesn't skip the password" do
    Contributor.create!(universe: @universe, email: 'invited@example.com')

    assert_not User.new.can_read?(@page)
  end

  test "the page itself stays closed" do
    as_each_outsider do
      get character_path(@page)
      assert_no_secrets
    end
  end

  test "its other routes stay closed" do
    sign_in @stranger

    get references_character_path(@page)
    assert_no_secrets

    get changelog_character_path(@page)
    assert_no_secrets

    get edit_character_path(@page)
    assert_no_secrets

    get character_path(@page, format: :json)
    assert_no_secrets
  end

  test "the owner's profile leaves it out" do
    as_each_outsider do
      get user_path(@author)
      assert_response :success
      assert_no_secrets

      get characters_user_path(@author)
      assert_response :success
      assert_no_secrets
    end
  end

  test "the universe's lists, table of contents and counts leave it out" do
    Character.create!(user: @author, universe: @universe, name: 'Open neighbour', privacy: 'private')

    as_each_outsider do
      get characters_universe_path(@universe)
      assert_response :success
      assert_no_secrets
      assert_includes response.body, 'Open neighbour'

      get universe_contents_path(@universe)
      assert_response :success
      assert_no_secrets

      get universe_path(@universe)
      assert_response :success
      assert_no_secrets
      assert_equal 1, controller.instance_variable_get(:@in_this_universe_count)
    end
  end

  test "the universe's lists and counts still show it to the owner" do
    sign_in @author

    get characters_universe_path(@universe)
    assert_shown

    get universe_path(@universe)
    assert_equal 1, controller.instance_variable_get(:@in_this_universe_count)
  end

  test "the name lookups and content links hide its name" do
    get "/api/internal/Character/#{@page.id}/name"
    assert_equal 'Private character', response.body

    assert_not_includes ContentFormatterService.show(text: "[[Character-#{@page.id}]]", viewing_user: User.new), SECRET_NAME
    assert_not_includes ContentFormatterService.show(text: "[[Character-#{@page.id}]]", viewing_user: @stranger), SECRET_NAME
    assert_includes ContentFormatterService.show(text: "[[Character-#{@page.id}]]", viewing_user: @author), SECRET_NAME

    sign_in @stranger
    get '/api/v1/page_name', params: { type: 'Character', id: @page.id }
    assert_response :forbidden
    assert_no_secrets
  end

  test "the API doesn't return it" do
    sign_in @stranger

    get "/api/v1/character/#{@page.id}"
    assert_no_secrets
  end

  test "old shares stop previewing it" do
    shared = Character.create!(user: @author, universe: @universe, name: 'Was shared', privacy: 'public')
    share = ContentPageShare.create!(user: @author, content_page: shared, message: 'hi', shared_at: DateTime.current)
    shared.protect_with_password(PASSWORD)

    get user_content_page_share_path(@author, share)
    assert_not_includes response.body, 'Was shared'

    sign_in @stranger
    get stream_world_path
    assert_not_includes response.body, 'Was shared'
  end

  test "it can't be shared by anyone, including its owner" do
    [@stranger, @author].each do |user|
      sign_in user

      assert_no_difference 'ContentPageShare.count' do
        post user_content_page_shares_path(user), params: { content_page_share: { content_page: "Character-#{@page.id}", message: 'hi' } }
      end

      assert @page.reload.password_protected?
      sign_out user
    end

    share = ContentPageShare.new(user: @author, content_page: @page, shared_at: DateTime.current)
    assert_not share.save
    assert_includes share.errors.full_messages.to_sentence, "Password protected pages can't be shared"
  end

  test "it can't be submitted to a collection, even by its owner" do
    collection = PageCollection.create!(user: @author, title: 'Mine', privacy: 'public', page_types: ['Character'])
    sign_in @author

    assert_no_difference 'PageCollectionSubmission.count' do
      post page_collection_submissions_path, params: { page_collection_submission: { content: "Character-#{@page.id}", page_collection_id: collection.id } }
    end

    assert @page.reload.password_protected?
  end

  test "its tags don't reach the owner's public tag pages" do
    @page.page_tags.create!(tag: 'Secret Tag', slug: 'secret-tag', user: @author)

    get user_id_tag_path(@author, 'secret-tag')
    assert_no_secrets

    get browse_tag_path('secret-tag')
    assert_no_secrets
  end

  test "it can't be linked to someone else's timeline" do
    timeline = Timeline.create!(name: 'Their timeline', user: @stranger, privacy: 'public')
    sign_in @stranger

    assert_no_difference 'TimelineEventEntity.count' do
      post "/plan/timeline_events/#{timeline.timeline_events.first.id}/link", params: { entity_type: 'Character', entity_id: @page.id }, as: :json
    end
  end

  test "the owner's own public timeline doesn't show it to readers" do
    timeline = Timeline.create!(name: 'My timeline', user: @author, privacy: 'public')
    timeline.timeline_events.first.timeline_event_entities.create!(entity: @page)

    as_each_outsider do
      get timeline_path(timeline)
      assert_response :success
      assert_no_secrets
    end
  end

  test "a public document's analysis doesn't name it" do
    document = Document.create!(user: @author, title: 'Open chapter', body: '<p>Text</p>', privacy: 'public')
    analysis = document.document_analysis.create!(queued_at: 1.hour.ago, completed_at: 1.hour.ago, progress: 100,
                                                  word_count: 100, sentence_count: 10, paragraph_count: 1, character_count: 500)
    analysis.document_entities.create!(entity: @page, entity_type: 'Character', text: SECRET_NAME)

    # Analysis pages need an account
    sign_in @stranger
    get analysis_document_path(document)
    assert_response :success
    assert_no_secrets

    sign_in @author
    get analysis_document_path(document)
    assert_shown
  end

  test "generic updates can't change its privacy" do
    sign_in @author

    patch character_path(@page), params: { character: { privacy: 'public' } }
    assert @page.reload.password_protected?

    other_page = Character.create!(user: @author, name: 'Other', privacy: 'private')
    patch character_path(other_page), params: { character: { privacy: 'password' } }
    assert_equal 'private', other_page.reload.privacy
  end

  test "contributors can't take it off either" do
    contributor = User.create!(name: 'Contributor', email: 'contributor@example.com', password: 'password123')
    Contributor.create!(universe: @universe, user: contributor)
    sign_in contributor

    patch character_path(@page), params: { character: { privacy: 'public' } }

    assert @page.reload.password_protected?
  end

  test "editing a protected page still saves" do
    sign_in @author

    patch character_path(@page), params: { character: { name: 'Renamed secret' } }

    assert_equal 'Renamed secret', @page.reload.name
    assert @page.password_protected?
  end
end
