require 'test_helper'

class ContributorRoleTest < ActiveSupport::TestCase
  def setup
    @owner       = users(:one)
    @collaborator = users(:two)

    @universe = Universe.create!(name: 'Role Test Universe', user: @owner, privacy: 'private')
  end

  def add_contributor(role)
    Contributor.create!(universe: @universe, email: @collaborator.email, user: @collaborator, role: role)
  end

  test "contributors default to the full role" do
    contributor = Contributor.create!(universe: @universe, email: @collaborator.email, user: @collaborator)
    assert_equal 'full', contributor.role
    assert_equal 'Full Contributor', contributor.role_label
  end

  test "invalid roles are rejected" do
    contributor = Contributor.new(universe: @universe, email: @collaborator.email, role: 'superadmin')
    refute contributor.valid?
    assert contributor.errors[:role].present?
  end

  test "role capability helpers" do
    full = add_contributor('full')
    assert full.can_edit_content?
    assert full.can_create_content?

    full.update!(role: 'editor')
    assert full.can_edit_content?
    refute full.can_create_content?

    full.update!(role: 'read_only')
    refute full.can_edit_content?
    refute full.can_create_content?
  end

  test "full contributors have read, edit, and create access to the universe" do
    add_contributor('full')

    assert_includes @collaborator.contributable_universe_ids, @universe.id
    assert_includes @collaborator.editable_universe_ids, @universe.id
    assert_includes @collaborator.creatable_universe_ids, @universe.id
  end

  test "editors have read and edit access but not create access" do
    add_contributor('editor')

    assert_includes @collaborator.contributable_universe_ids, @universe.id
    assert_includes @collaborator.editable_universe_ids, @universe.id
    refute_includes @collaborator.creatable_universe_ids, @universe.id
  end

  test "read-only contributors have read access only" do
    add_contributor('read_only')

    assert_includes @collaborator.contributable_universe_ids, @universe.id
    refute_includes @collaborator.editable_universe_ids, @universe.id
    refute_includes @collaborator.creatable_universe_ids, @universe.id
  end

  test "permission service exposes role-aware universe checks" do
    contributor = add_contributor('editor')

    assert PermissionService.user_can_contribute_to_universe?(user: @collaborator, universe: @universe)
    assert PermissionService.user_can_edit_universe_content?(user: @collaborator, universe: @universe)
    refute PermissionService.user_can_create_universe_content?(user: @collaborator, universe: @universe)

    contributor.update!(role: 'read_only')
    @collaborator.reload
    fresh_collaborator = User.find(@collaborator.id)

    assert PermissionService.user_can_contribute_to_universe?(user: fresh_collaborator, universe: @universe)
    refute PermissionService.user_can_edit_universe_content?(user: fresh_collaborator, universe: @universe)
    refute PermissionService.user_can_create_universe_content?(user: fresh_collaborator, universe: @universe)
  end

  test "content in the universe is editable by editors but not read-only contributors" do
    character = Character.create!(name: 'Universe Character', user: @owner, universe: @universe, privacy: 'private')

    contributor = add_contributor('editor')
    editor = User.find(@collaborator.id)
    assert character.readable_by?(editor)
    assert character.updatable_by?(editor)

    contributor.update!(role: 'read_only')
    read_only = User.find(@collaborator.id)
    assert character.readable_by?(read_only)
    refute character.updatable_by?(read_only)

    # A user who isn't a contributor at all can't see private content
    contributor.destroy
    stranger = User.find(@collaborator.id)
    refute character.readable_by?(stranger)
    refute character.updatable_by?(stranger)
  end

  test "the universe page itself is editable by editors but not read-only contributors" do
    contributor = add_contributor('editor')
    editor = User.find(@collaborator.id)
    assert @universe.updatable_by?(editor)

    contributor.update!(role: 'read_only')
    read_only = User.find(@collaborator.id)
    assert @universe.readable_by?(read_only)
    refute @universe.updatable_by?(read_only)
  end

  test "universe owners retain full access regardless of contributor roles" do
    add_contributor('read_only')
    owner = User.find(@owner.id)

    assert_includes owner.editable_universe_ids, @universe.id
    assert_includes owner.creatable_universe_ids, @universe.id
  end
end
