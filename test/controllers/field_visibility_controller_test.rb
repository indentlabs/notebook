require 'test_helper'

class FieldVisibilityControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @owner        = users(:one)
    @collaborator = users(:two)

    @universe  = Universe.create!(name: 'Field Guard Universe', user: @owner, privacy: 'private')
    @character = Character.create!(name: 'Guarded Character', user: @owner, universe: @universe)

    @category = AttributeCategory.create!(
      user:        @owner,
      entity_type: 'character',
      name:        'field_guard_test',
      label:       'Field Guard Test'
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

  def update_field(field, value)
    patch text_field_update_path(field.id), params: {
      entity: { entity_type: 'Character', entity_id: @character.id },
      field:  { value: value }
    }, headers: { 'Accept' => 'application/json' }
  end

  def value_of(field)
    Attribute.find_by(attribute_field_id: field.id, entity_type: 'Character', entity_id: @character.id)&.value
  end

  test "editors can write to contributors-only fields" do
    field = build_field('contributors')
    Contributor.create!(universe: @universe, email: @collaborator.email, user: @collaborator, role: 'editor')
    sign_in @collaborator

    update_field(field, 'written by editor')

    assert_response :success
    assert_equal 'written by editor', value_of(field)
  end

  test "editors cannot write to private fields" do
    field = build_field('private')
    Contributor.create!(universe: @universe, email: @collaborator.email, user: @collaborator, role: 'editor')
    sign_in @collaborator

    update_field(field, 'should not save')

    assert_response :forbidden
    assert_nil value_of(field)
  end

  test "owners can write to their own private fields" do
    field = build_field('private')
    sign_in @owner

    update_field(field, 'owner secret')

    assert_response :success
    assert_equal 'owner secret', value_of(field)
  end

  test "field visibility can be updated by the template owner" do
    field = build_field('public')
    sign_in @owner

    put polymorphic_path(field), params: {
      attribute_field: { privacy: 'contributors' }
    }, headers: { 'Accept' => 'application/json' }

    assert_equal 'contributors', field.reload.privacy
  end

  test "field visibility rejects invalid values" do
    field = build_field('public')
    sign_in @owner

    put polymorphic_path(field), params: {
      attribute_field: { privacy: 'everyone-but-dave' }
    }, headers: { 'Accept' => 'application/json' }

    assert_equal 'public', field.reload.privacy
  end
end
