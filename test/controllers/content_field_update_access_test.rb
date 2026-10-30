require 'test_helper'

# Field updates say which page they're for in their params, so the page has to be checked
# before anything gets written to it.
class ContentFieldUpdateAccessTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @owner    = users(:one)
    @stranger = users(:two)
    @page     = Character.create!(user: @owner, name: 'Original name', privacy: 'private')
  end

  def field_for(user, field_type)
    category = AttributeCategory.create!(user: user, name: 'overview', label: 'Overview', entity_type: 'character')
    AttributeField.create!(user: user, attribute_category: category, label: field_type, name: field_type, field_type: field_type)
  end

  def entity(page = @page)
    { entity_type: page.class.name, entity_id: page.id }
  end

  def update_field(action, field, params)
    patch "/internal/#{action}_field_update/#{field.id}", params: { entity: entity }.merge(params), as: :json
  end

  def share_universe_with(user)
    universe = Universe.create!(user: @owner, name: 'Shared', privacy: 'private')
    Contributor.create!(universe: universe, user: user, email: user.email)
    @page.update!(universe: universe)
    universe
  end

  test "strangers can't change a page's answers" do
    field = field_for(@owner, 'text_area')
    sign_in @stranger

    update_field('text', field, field: { value: 'Overwritten' })

    assert_response :forbidden
    assert_not Attribute.exists?(entity_type: 'Character', entity_id: @page.id, value: 'Overwritten')
  end

  test "signed out visitors can't change a page's answers" do
    field = field_for(@owner, 'text_area')

    update_field('text', field, field: { value: 'Overwritten' })

    assert_response :unauthorized
    assert_not Attribute.exists?(entity_type: 'Character', entity_id: @page.id, value: 'Overwritten')
  end

  test "strangers can't rename a page" do
    field = field_for(@owner, 'name')
    sign_in @stranger

    update_field('name', field, field: { value: 'Renamed' })

    assert_response :forbidden
    assert_equal 'Original name', @page.reload.name
  end

  test "strangers can't change a page's tags" do
    field = field_for(@owner, 'tags')
    @page.page_tags.create!(tag: 'Kept', slug: 'kept', user: @owner)
    sign_in @stranger

    update_field('tags', field, field: { value: '' })

    assert_response :forbidden
    assert_equal ['Kept'], @page.page_tags.pluck(:tag)
  end

  test "strangers can't change a page's links" do
    field = field_for(@owner, 'link')
    target = Location.create!(user: @stranger, name: 'Theirs', privacy: 'public')
    sign_in @stranger

    update_field('link', field, attribute_field: { linked_pages: ["Location-#{target.id}"] })

    assert_response :forbidden
    assert_equal 0, @page.outgoing_page_references.count
  end

  test "strangers can't move a page into their universe" do
    field = field_for(@owner, 'universe')
    theirs = Universe.create!(user: @stranger, name: 'Theirs', privacy: 'private')
    sign_in @stranger

    update_field('universe', field, field: { value: theirs.id })

    assert_response :forbidden
    assert_nil @page.reload.universe_id
  end

  test "strangers can't move a page with a universe field of their own" do
    field = field_for(@stranger, 'universe')
    theirs = Universe.create!(user: @stranger, name: 'Theirs', privacy: 'private')
    sign_in @stranger

    update_field('text', field, field: { value: theirs.id })

    assert_response :forbidden
    assert_nil @page.reload.universe_id
  end

  test "field updates only work on page types" do
    document = Document.create!(user: @owner, title: 'Mine', body: 'text', privacy: 'private')
    field = field_for(@stranger, 'universe')
    theirs = Universe.create!(user: @stranger, name: 'Theirs', privacy: 'private')
    sign_in @stranger

    patch "/internal/text_field_update/#{field.id}", params: { entity: entity(document), field: { value: theirs.id } }, as: :json

    assert_response :forbidden
    assert_nil document.reload.universe_id
  end

  test "the owner can update their page's fields" do
    sign_in @owner

    update_field('text', field_for(@owner, 'text_area'), field: { value: 'Answer' })
    assert_response :success
    assert Attribute.exists?(entity_type: 'Character', entity_id: @page.id, value: 'Answer')

    update_field('name', field_for(@owner, 'name'), field: { value: 'Renamed' })
    assert_response :success
    assert_equal 'Renamed', @page.reload.name

    update_field('tags', field_for(@owner, 'tags'), field: { value: 'Tagged' })
    assert_response :success
    assert_equal ['Tagged'], @page.page_tags.pluck(:tag)

    target = Location.create!(user: @owner, name: 'Mine', privacy: 'public')
    update_field('link', field_for(@owner, 'link'), attribute_field: { linked_pages: ["Location-#{target.id}"] })
    assert_response :success
    assert_equal 1, @page.outgoing_page_references.count
  end

  test "the owner can move their page into their universe and back out" do
    field = field_for(@owner, 'universe')
    mine = Universe.create!(user: @owner, name: 'Mine', privacy: 'private')
    sign_in @owner

    update_field('universe', field, field: { value: mine.id })
    assert_response :success
    assert_equal mine.id, @page.reload.universe_id

    update_field('universe', field, field: { value: '' })
    assert_response :success
    assert_nil @page.reload.universe_id
  end

  test "the owner can't move their page into someone else's universe" do
    field = field_for(@owner, 'universe')
    theirs = Universe.create!(user: @stranger, name: 'Theirs', privacy: 'private')
    sign_in @owner

    update_field('universe', field, field: { value: theirs.id })

    assert_response :forbidden
    assert_nil @page.reload.universe_id
  end

  test "a universe field only saves through the universe update" do
    field = field_for(@owner, 'universe')
    mine = Universe.create!(user: @owner, name: 'Mine', privacy: 'private')
    sign_in @owner

    update_field('text', field, field: { value: mine.id })

    assert_response :forbidden
    assert_nil @page.reload.universe_id
  end

  test "a universe contributor can edit a page but not move it" do
    universe = share_universe_with(@stranger)
    sign_in @stranger

    update_field('text', field_for(@owner, 'text_area'), field: { value: 'Answer' })
    assert_response :success

    update_field('universe', field_for(@owner, 'universe'), field: { value: '' })
    assert_response :forbidden
    assert_equal universe.id, @page.reload.universe_id
  end
end
