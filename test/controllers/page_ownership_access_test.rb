require 'test_helper'

# Who owns a page, whether it's deleted, and which universe it's in are all decided
# by the page's owner, even though contributors can edit the rest of it.
class PageOwnershipAccessTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @owner       = users(:one)
    @contributor = users(:two)
    @universe    = Universe.create!(user: @owner, name: 'Shared', privacy: 'private')
    Contributor.create!(universe: @universe, user: @contributor, email: @contributor.email)
    @page = Character.create!(user: @owner, name: 'Shared page', privacy: 'private', universe: @universe)
    @theirs = Universe.create!(user: User.create!(email: 'other@example.com', password: 'password', password_confirmation: 'password'), name: 'Theirs', privacy: 'private')
  end

  test "contributors can't take over a universe" do
    sign_in @contributor

    patch universe_path(@universe), params: { universe: { user_id: @contributor.id } }

    assert_equal @owner.id, @universe.reload.user_id
  end

  test "contributors can't take over a page" do
    sign_in @contributor

    patch character_path(@page), params: { character: { user_id: @contributor.id } }

    assert_equal @owner.id, @page.reload.user_id
  end

  test "contributors can't delete a universe or page through an update" do
    sign_in @contributor

    patch universe_path(@universe), params: { universe: { deleted_at: Time.current } }
    assert Universe.exists?(@universe.id)

    patch character_path(@page), params: { character: { deleted_at: Time.current } }
    assert Character.exists?(@page.id)
  end

  test "contributors can still edit a page" do
    sign_in @contributor

    patch character_path(@page), params: { character: { name: 'Renamed' } }

    assert_equal 'Renamed', @page.reload.name
  end

  test "owners can't give a page away" do
    sign_in @owner

    patch character_path(@page), params: { character: { user_id: @contributor.id } }

    assert_equal @owner.id, @page.reload.user_id
  end

  test "owners can still delete their page through an update" do
    sign_in @owner

    patch character_path(@page), params: { character: { deleted_at: Time.current } }

    assert_not Character.exists?(@page.id)
  end

  test "nobody can make a page in someone else's universe" do
    sign_in @contributor

    post characters_path, params: { character: { name: 'Planted', universe_id: @theirs.id }, field: { value: '' } }

    assert_not Character.exists?(name: 'Planted', universe_id: @theirs.id)
  end

  test "contributors can make a page in a universe they contribute to" do
    sign_in @contributor

    post characters_path, params: { character: { name: 'Added', universe_id: @universe.id }, field: { value: '' } }

    assert Character.exists?(name: 'Added', universe_id: @universe.id, user_id: @contributor.id)
  end

  test "nobody can move their book or document into someone else's universe" do
    book     = Book.create!(user: @contributor, name: 'Mine', privacy: 'private')
    document = Document.create!(user: @contributor, title: 'Mine', body: 'text', privacy: 'private')
    sign_in @contributor

    patch book_path(book), params: { book: { universe_id: @theirs.id } }
    assert_nil book.reload.universe_id

    patch document_path(document), params: { document: { universe_id: @theirs.id } }, as: :json
    assert_nil document.reload.universe_id
  end

  test "a contributor can't move a timeline out of its universe" do
    timeline = Timeline.create!(user: @owner, name: 'Shared timeline', privacy: 'private', universe: @universe)
    sign_in @contributor

    patch timeline_path(timeline), params: { timeline: { name: 'Renamed', universe_id: '' } }

    assert_equal @universe.id, timeline.reload.universe_id
  end
end
