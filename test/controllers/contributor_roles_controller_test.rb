require 'test_helper'

class ContributorRolesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @owner        = users(:one)
    @collaborator = users(:two)
    @universe     = Universe.create!(name: 'Role Enforcement Universe', user: @owner, privacy: 'private')
  end

  def add_contributor(role)
    Contributor.create!(universe: @universe, email: @collaborator.email, user: @collaborator, role: role)
  end

  test "full contributors can create pages in the universe" do
    add_contributor('full')
    sign_in @collaborator

    assert_difference 'Character.count', 1 do
      post characters_path, params: {
        character: { universe_id: @universe.id },
        field: { value: '' }
      }
    end
    assert_equal @universe.id, Character.last.universe_id
  end

  test "editors cannot create pages in the universe" do
    add_contributor('editor')
    sign_in @collaborator

    assert_no_difference 'Character.count' do
      post characters_path, params: { character: { universe_id: @universe.id } }
    end
    assert_response :redirect
  end

  test "read-only contributors cannot create pages in the universe" do
    add_contributor('read_only')
    sign_in @collaborator

    assert_no_difference 'Character.count' do
      post characters_path, params: { character: { universe_id: @universe.id } }
    end
    assert_response :redirect
  end

  test "non-contributors cannot create pages in someone else's universe" do
    sign_in @collaborator

    assert_no_difference 'Character.count' do
      post characters_path, params: { character: { universe_id: @universe.id } }
    end
    assert_response :redirect
  end

  test "read-only contributors cannot update fields on universe content" do
    character = Character.create!(name: 'Guarded Character', user: @owner, universe: @universe)
    field = name_field_for(character)

    add_contributor('read_only')
    sign_in @collaborator

    patch name_field_update_path(field.id), params: {
      entity: { entity_type: 'Character', entity_id: character.id },
      field:  { value: 'Hacked Name' }
    }, headers: { 'Accept' => 'application/json' }

    assert_response :forbidden
    assert_equal 'Guarded Character', character.reload.name
  end

  test "editors can update fields on universe content" do
    character = Character.create!(name: 'Editable Character', user: @owner, universe: @universe)
    field = name_field_for(character)

    add_contributor('editor')
    sign_in @collaborator

    patch name_field_update_path(field.id), params: {
      entity: { entity_type: 'Character', entity_id: character.id },
      field:  { value: 'Renamed by Editor' }
    }, headers: { 'Accept' => 'application/json' }

    assert_response :success
    assert_equal 'Renamed by Editor', character.reload.name
  end

  test "owner can change a contributor role" do
    contributor = add_contributor('full')
    sign_in @owner

    patch update_contributor_role_path(contributor.id), params: { contributor: { role: 'read_only' } }

    assert_redirected_to edit_universe_path(@universe, anchor: 'contributors')
    assert_equal 'read_only', contributor.reload.role
  end

  test "non-owners cannot change contributor roles" do
    contributor = add_contributor('editor')
    sign_in @collaborator

    patch update_contributor_role_path(contributor.id), params: { contributor: { role: 'full' } }

    assert_equal 'editor', contributor.reload.role
  end

  test "invalid roles are rejected on role change" do
    contributor = add_contributor('full')
    sign_in @owner

    patch update_contributor_role_path(contributor.id), params: { contributor: { role: 'owner' } }

    assert_equal 'full', contributor.reload.role
  end

  test "invites can specify a role" do
    sign_in @owner

    post universe_contributors_path(@universe), params: {
      contributor: { email: 'neweditor@example.com', role: 'editor' }
    }

    contributor = @universe.contributors.find_by(email: 'neweditor@example.com')
    assert contributor.present?
    assert_equal 'editor', contributor.role
  end

  test "invites with an invalid role fall back to full" do
    sign_in @owner

    post universe_contributors_path(@universe), params: {
      contributor: { email: 'newfull@example.com', role: 'bogus' }
    }

    contributor = @universe.contributors.find_by(email: 'newfull@example.com')
    assert contributor.present?
    assert_equal 'full', contributor.role
  end

  private

  # The name field is created lazily per content type per user; make sure it exists
  def name_field_for(content)
    categories = content.class.attribute_categories(content.user)
    if categories.empty?
      content.class.create_default_attribute_categories(content.user)
      categories = content.class.attribute_categories(content.user)
    end

    AttributeField.where(attribute_category_id: categories.map(&:id), field_type: 'name').first
  end
end
