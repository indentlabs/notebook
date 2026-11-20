require 'test_helper'

class ExportServiceJsonTest < ActiveSupport::TestCase
  def setup
    @user     = User.first
    @universe = Universe.create!(user: @user, name: 'Export Test Universe')

    @category = AttributeCategory.create!(
      user:        @user,
      name:        'export_overview',
      label:       'Export Overview',
      entity_type: 'character'
    )
    @field = AttributeField.create!(
      user:               @user,
      attribute_category: @category,
      label:              'Role',
      name:               'export_role',
      field_type:         'text_area'
    )

    @first  = Character.create!(user: @user, universe: @universe, name: 'First Exported')
    @second = Character.create!(user: @user, universe: @universe, name: 'Second Exported')

    Attribute.create!(user: @user, attribute_field: @field, entity: @first,  value: 'first role')
    Attribute.create!(user: @user, attribute_field: @field, entity: @second, value: 'second role')
  end

  def exported_characters
    JSON.parse(ExportService.json_export([@universe.id])).fetch('Character')
  end

  test "exports one record per page, not one per page type" do
    characters = exported_characters

    assert_equal 2, characters.size
    assert_equal [@first.id, @second.id].sort, characters.map { |c| c['id'] }.sort
  end

  test "each exported record keeps its own name and field values" do
    by_id = exported_characters.index_by { |c| c['id'] }

    assert_equal 'First Exported',  by_id[@first.id]['name']
    assert_equal 'first role',      by_id[@first.id]['Export Overview']['Role']
    assert_equal 'Second Exported', by_id[@second.id]['name']
    assert_equal 'second role',     by_id[@second.id]['Export Overview']['Role']
  end
end
