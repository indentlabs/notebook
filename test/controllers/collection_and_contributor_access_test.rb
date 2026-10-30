require 'test_helper'

class CollectionAndContributorAccessTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  SECRET = 'SECRETNAME'

  setup do
    @owner    = users(:one)
    @stranger = users(:two)
    @writer   = User.create!(email: 'writer@example.com', password: 'password', password_confirmation: 'password')
    # Fixture shares point at nothing, which the feed can't render
    ContentPageShare.update_all(deleted_at: Time.current)
  end

  def collection(**attributes)
    PageCollection.create!({ user: @owner, title: 'Collection', privacy: 'public', page_types: ['Character'] }.merge(attributes))
  end

  def accepted_page(in_collection, privacy: 'public')
    page = Character.create!(user: @writer, name: SECRET, privacy: 'public')
    PageCollectionSubmission.create!(page_collection: in_collection, content: page, user: @writer, submitted_at: Time.current, accepted_at: Time.current)
    page.update!(privacy: privacy)
    page
  end

  def submit(to_collection, page)
    post page_collection_submissions_path, params: {
      page_collection_submission: { content: "#{page.class.name}-#{page.id}", page_collection_id: to_collection.id, explanation: 'Please' }
    }
  end

  test "a private collection's page type views are only for its owner" do
    private_collection = collection(title: SECRET, privacy: 'private')
    sign_in @stranger

    get characters_page_collection_path(private_collection)

    assert_redirected_to page_collections_path
    assert_not_includes response.body, SECRET

    sign_in @owner
    get characters_page_collection_path(private_collection)
    assert_response :success
  end

  test "a page that has gone private drops out of a collection's views" do
    shown = collection
    accepted_page(shown, privacy: 'private')
    sign_in @stranger

    [
      page_collection_path(shown),
      characters_page_collection_path(shown),
      rss_page_collection_path(shown),
      pages_page_collection_path(shown),
      page_collection_submissions_by_user_path(shown, @writer)
    ].each do |path|
      get path

      assert_response :success, path
      assert_not_includes response.body, SECRET, path
    end
  end

  test "a public page still shows in a collection's views" do
    shown = collection
    accepted_page(shown)
    sign_in @stranger

    [
      page_collection_path(shown),
      characters_page_collection_path(shown),
      rss_page_collection_path(shown),
      pages_page_collection_path(shown),
      page_collection_submissions_by_user_path(shown, @writer)
    ].each do |path|
      get path

      assert_includes response.body, SECRET, path
    end
  end

  test "a page that's gone private still shows in a collection to its author" do
    shown = collection
    accepted_page(shown, privacy: 'private')
    sign_in @writer

    get page_collection_path(shown)

    assert_includes response.body, SECRET
  end

  test "nobody can submit to a collection that isn't taking submissions" do
    closed = collection(allow_submissions: false)
    page   = Character.create!(user: @stranger, name: 'Mine', privacy: 'public')
    sign_in @stranger

    submit(closed, page)

    assert_not PageCollectionSubmission.exists?(page_collection: closed)
  end

  test "nobody can submit to someone else's private collection" do
    hidden = collection(allow_submissions: true, privacy: 'private')
    page   = Character.create!(user: @stranger, name: 'Mine', privacy: 'public')
    sign_in @stranger

    submit(hidden, page)

    assert_not PageCollectionSubmission.exists?(page_collection: hidden)
  end

  test "nobody can submit a page type a collection doesn't take" do
    open_collection = collection(allow_submissions: true)
    page = Location.create!(user: @stranger, name: 'Mine', privacy: 'public')
    sign_in @stranger

    submit(open_collection, page)

    assert_not PageCollectionSubmission.exists?(page_collection: open_collection)
  end

  test "people can submit to an open collection, and owners can add to their own" do
    open_collection = collection(allow_submissions: true)
    page = Character.create!(user: @stranger, name: 'Mine', privacy: 'public')
    sign_in @stranger
    submit(open_collection, page)
    assert PageCollectionSubmission.exists?(page_collection: open_collection, content: page)

    closed = collection(allow_submissions: false)
    mine   = Character.create!(user: @owner, name: 'Mine', privacy: 'public')
    sign_in @owner
    submit(closed, mine)
    assert PageCollectionSubmission.exists?(page_collection: closed, content: mine)
  end

  test "signed out visitors can't submit to a collection" do
    open_collection = collection(allow_submissions: true)
    page = Character.create!(user: @stranger, name: 'Mine', privacy: 'public')

    submit(open_collection, page)

    assert_redirected_to new_user_session_path
    assert_not PageCollectionSubmission.exists?(page_collection: open_collection)
  end

  test "strangers can't remove a contributor from a universe" do
    universe    = Universe.create!(user: @owner, name: 'Shared', privacy: 'private')
    contributor = Contributor.create!(universe: universe, user: @writer, email: @writer.email)
    sign_in @stranger

    delete remove_contributor_path(contributor)

    assert_response :redirect
    assert Contributor.exists?(contributor.id)
  end

  test "a universe's owner can remove a contributor, and contributors can leave" do
    universe = Universe.create!(user: @owner, name: 'Shared', privacy: 'private')
    removed  = Contributor.create!(universe: universe, user: @writer, email: @writer.email)
    leaving  = Contributor.create!(universe: universe, user: @stranger, email: @stranger.email)

    sign_in @owner
    delete remove_contributor_path(removed)
    assert_not Contributor.exists?(removed.id)
    sign_out @owner

    sign_in @stranger
    delete remove_contributor_path(leaving)
    assert_not Contributor.exists?(leaving.id)
  end
end
