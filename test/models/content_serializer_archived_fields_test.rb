require 'test_helper'

class ContentSerializerArchivedFieldsTest < ActiveSupport::TestCase
  def setup
    @user = User.first

    @category = AttributeCategory.create!(
      user:        @user,
      name:        'overview',
      label:       'Overview',
      entity_type: 'character'
    )

    @active_field = AttributeField.create!(
      user:               @user,
      attribute_category: @category,
      label:              'Role',
      name:               'role',
      field_type:         'text_area'
    )

    @archived_field = AttributeField.create!(
      user:               @user,
      attribute_category: @category,
      label:              'Old Notes',
      name:               'old_notes',
      field_type:         'text_area',
      hidden:             true
    )

    @archived_category = AttributeCategory.create!(
      user:        @user,
      name:        'retired',
      label:       'Retired',
      entity_type: 'character',
      hidden:      true
    )

    @field_in_archived_category = AttributeField.create!(
      user:               @user,
      attribute_category: @archived_category,
      label:              'Retired Detail',
      name:               'retired_detail',
      field_type:         'text_area'
    )

    @character = Character.create!(user: @user, name: 'Archivist')

    [@active_field, @archived_field, @field_in_archived_category].each do |field|
      Attribute.create!(
        user:            @user,
        attribute_field: field,
        entity:          @character,
        value:           "value for #{field.label}"
      )
    end
  end

  def serialized_field_labels
    ContentSerializer.new(@character, viewing_user: @user)
      .data[:categories]
      .flat_map { |category| category[:fields] }
      .map { |field| field[:label] }
  end

  test "archived fields are left out of serialized page content" do
    refute_includes serialized_field_labels, 'Old Notes'
  end

  test "active fields in the same category are still serialized" do
    assert_includes serialized_field_labels, 'Role'
  end

  test "fields belonging to an archived category are left out too" do
    refute_includes serialized_field_labels, 'Retired Detail'
  end

  test "archiving a field doesn't touch its stored answer" do
    assert_equal 'value for Old Notes',
      Attribute.find_by(attribute_field: @archived_field, entity: @character).value
  end

  test "restoring an archived field brings its answer back to the page" do
    @archived_field.update!(hidden: false)

    fields = ContentSerializer.new(@character, viewing_user: @user)
      .data[:categories]
      .flat_map { |category| category[:fields] }

    restored = fields.detect { |field| field[:label] == 'Old Notes' }
    assert restored.present?, 'expected the restored field to be serialized again'
    assert_equal 'value for Old Notes', restored[:value]
  end

  test "an archived name field is still serialized so pages keep a name" do
    name_field = AttributeField.create!(
      user:               @user,
      attribute_category: @category,
      label:              'Name',
      name:               'name',
      field_type:         'name',
      hidden:             true
    )

    serialized_ids = ContentSerializer.new(@character, viewing_user: @user)
      .data[:categories]
      .flat_map { |category| category[:fields] }
      .map { |field| field[:internal_id] }

    assert_includes serialized_ids, name_field.id
  end
end
