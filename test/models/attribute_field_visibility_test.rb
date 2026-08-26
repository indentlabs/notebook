require 'test_helper'

class AttributeFieldVisibilityTest < ActiveSupport::TestCase
  def setup
    @owner        = users(:one)
    @collaborator = users(:two)
    @stranger     = User.create!(email: 'stranger@example.com', password: 'password123')

    @universe  = Universe.create!(name: 'Visibility Universe', user: @owner, privacy: 'public')
    @character = Character.create!(name: 'Visible Character', user: @owner, universe: @universe, privacy: 'public')

    @category = AttributeCategory.create!(
      user:        @owner,
      entity_type: 'character',
      name:        'visibility_test',
      label:       'Visibility Test'
    )
  end

  def build_field(privacy)
    AttributeField.create!(
      user:               @owner,
      attribute_category: @category,
      label:              "#{privacy.humanize} Field",
      field_type:         'text_area',
      privacy:            privacy
    )
  end

  def add_contributor(role)
    Contributor.create!(universe: @universe, email: @collaborator.email, user: @collaborator, role: role)
  end

  test "privacy validation accepts only known visibility levels" do
    assert build_field('public').valid?
    assert build_field('contributors').valid?
    assert build_field('private').valid?

    invalid = AttributeField.new(
      user: @owner, attribute_category: @category, label: 'Bad', field_type: 'text_area', privacy: 'friends'
    )
    refute invalid.valid?
    assert invalid.errors[:privacy].present?
  end

  test "effective_privacy prefers the privacy column and falls back for legacy private notes" do
    field = build_field('contributors')
    assert_equal 'contributors', field.effective_privacy

    legacy = AttributeField.create!(
      user: @owner, attribute_category: @category, label: 'Private Notes',
      field_type: 'text_area', old_column_source: 'private_notes'
    )
    # Default column value is 'public', but legacy private notes stay private
    assert_equal 'private', legacy.effective_privacy
    refute legacy.can_be_public?

    # Owners can open legacy private notes up to contributors
    legacy.update!(privacy: 'contributors')
    assert_equal 'contributors', legacy.effective_privacy
  end

  test "public fields are visible to everyone including logged-out viewers" do
    field = build_field('public')

    assert PermissionService.attribute_field_visible_to?(field: field, content: @character, viewer: nil)
    assert PermissionService.attribute_field_visible_to?(field: field, content: @character, viewer: @stranger)
  end

  test "contributors-only fields are visible to owner, universe owner, and contributors of any role" do
    field = build_field('contributors')

    refute PermissionService.attribute_field_visible_to?(field: field, content: @character, viewer: nil)
    refute PermissionService.attribute_field_visible_to?(field: field, content: @character, viewer: @stranger)

    assert PermissionService.attribute_field_visible_to?(field: field, content: @character, viewer: @owner)

    add_contributor('read_only')
    reader = User.find(@collaborator.id)
    assert PermissionService.attribute_field_visible_to?(field: field, content: @character, viewer: reader)
  end

  test "contributors-only fields on pages outside any universe are owner-only" do
    field = build_field('contributors')
    loner = Character.create!(name: 'No Universe', user: @owner, privacy: 'public')

    assert PermissionService.attribute_field_visible_to?(field: field, content: loner, viewer: @owner)
    refute PermissionService.attribute_field_visible_to?(field: field, content: loner, viewer: @stranger)
  end

  test "private fields are visible only to the page owner" do
    field = build_field('private')

    assert PermissionService.attribute_field_visible_to?(field: field, content: @character, viewer: @owner)

    add_contributor('full')
    contributor = User.find(@collaborator.id)
    refute PermissionService.attribute_field_visible_to?(field: field, content: @character, viewer: contributor)
    refute PermissionService.attribute_field_visible_to?(field: field, content: @character, viewer: @stranger)
    refute PermissionService.attribute_field_visible_to?(field: field, content: @character, viewer: nil)
  end

  test "contributors-only fields on a universe page are visible to that universe's contributors" do
    universe_category = AttributeCategory.create!(
      user: @owner, entity_type: 'universe', name: 'universe_visibility', label: 'Universe Visibility'
    )
    field = AttributeField.create!(
      user: @owner, attribute_category: universe_category,
      label: 'Contributor Lore', field_type: 'text_area', privacy: 'contributors'
    )

    refute PermissionService.attribute_field_visible_to?(field: field, content: @universe, viewer: @stranger)

    add_contributor('read_only')
    reader = User.find(@collaborator.id)
    assert PermissionService.attribute_field_visible_to?(field: field, content: @universe, viewer: reader)
  end

  test "content serializer strips fields the viewer can't see" do
    field = build_field('contributors')
    Attribute.create!(
      user: @owner, attribute_field: field,
      entity_type: 'Character', entity_id: @character.id, value: 'contributor secret'
    )
    private_field = build_field('private')
    Attribute.create!(
      user: @owner, attribute_field: private_field,
      entity_type: 'Character', entity_id: @character.id, value: 'owner secret'
    )

    add_contributor('read_only')
    contributor = User.find(@collaborator.id)

    owner_labels       = serialized_field_labels(viewer: @owner)
    contributor_labels = serialized_field_labels(viewer: contributor)
    stranger_labels    = serialized_field_labels(viewer: @stranger)
    public_labels      = serialized_field_labels(viewer: nil)

    assert_includes owner_labels, 'Contributors Field'
    assert_includes owner_labels, 'Private Field'

    assert_includes contributor_labels, 'Contributors Field'
    refute_includes contributor_labels, 'Private Field'

    refute_includes stranger_labels, 'Contributors Field'
    refute_includes stranger_labels, 'Private Field'

    refute_includes public_labels, 'Contributors Field'
    refute_includes public_labels, 'Private Field'
  end

  test "api serializer strips fields the viewer can't see" do
    field = build_field('contributors')
    Attribute.create!(
      user: @owner, attribute_field: field,
      entity_type: 'Character', entity_id: @character.id, value: 'contributor secret'
    )

    add_contributor('read_only')
    contributor = User.find(@collaborator.id)

    owner_labels       = api_field_labels(viewer: @owner)
    contributor_labels = api_field_labels(viewer: contributor)
    stranger_labels    = api_field_labels(viewer: @stranger)
    anonymous_labels   = api_field_labels(viewer: nil)

    assert_includes owner_labels, 'Contributors Field'
    assert_includes contributor_labels, 'Contributors Field'
    refute_includes stranger_labels, 'Contributors Field'
    refute_includes anonymous_labels, 'Contributors Field'
  end

  private

  def serialized_field_labels(viewer:)
    data = ContentSerializer.new(@character.reload, viewing_user: viewer).data
    data[:categories].flat_map { |category| category[:fields].map { |f| f[:label] } }
  end

  def api_field_labels(viewer:)
    data = ApiContentSerializer.new(@character.reload, include_blank_fields: true, viewer: viewer).data
    data[:categories].flat_map { |category| category[:fields].map { |f| f[:label] } }
  end
end
