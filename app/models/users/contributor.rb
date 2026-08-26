class Contributor < ApplicationRecord
  belongs_to :universe
  belongs_to :user, optional: true

  # Roles, from most to least permissive:
  # - full:      can view, edit, and create content in the universe
  # - editor:    can view and edit existing content, but not create new content
  # - read_only: can view all content in the universe, but not edit anything
  ROLES = {
    'full'      => 'Full Contributor',
    'editor'    => 'Editor',
    'read_only' => 'Read-Only'
  }.freeze

  # Roles that grant write access to existing content
  EDITING_ROLES = %w(full editor).freeze

  # Roles that grant the ability to create new content in the universe
  CREATING_ROLES = %w(full).freeze

  validates :role, inclusion: { in: ROLES.keys }

  def role_label
    ROLES.fetch(role, ROLES.fetch('full'))
  end

  def can_edit_content?
    EDITING_ROLES.include?(role)
  end

  def can_create_content?
    CREATING_ROLES.include?(role)
  end

  def role_description
    case role
    when 'full'      then 'Can view, edit, and create content in this universe'
    when 'editor'    then 'Can view and edit existing content, but not create new pages'
    when 'read_only' then 'Can view all content in this universe, but not edit anything'
    end
  end
end
