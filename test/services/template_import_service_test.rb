require 'test_helper'

class TemplateImportServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)

    @category = @user.attribute_categories.create!(
      entity_type: 'character',
      name: 'overview',
      label: 'Overview',
      icon: 'info'
    )
    @role_field = @category.attribute_fields.create!(
      user: @user, name: 'role', label: 'Role', field_type: 'text_area'
    )
  end

  def export_hash(categories)
    { 'template' => { 'content_type' => 'character', 'categories' => categories } }
  end

  def service(content, filename: 'character_template.json', content_type: 'character')
    TemplateImportService.new(@user, content_type, content, filename: filename)
  end

  def one_category_json(fields)
    JSON.generate(export_hash(
      'overview' => { 'label' => 'Overview', 'icon' => 'info', 'fields' => fields }
    ))
  end

  # --- parsing ---------------------------------------------------------------

  test 'rejects an unsupported file type' do
    result = service('anything', filename: 'template.txt').analyze
    refute result[:success]
    assert_match(/Unsupported file type/, result[:error])
  end

  test 'rejects a blank upload' do
    result = service('', filename: 'template.json').analyze
    refute result[:success]
    assert_match(/No template file/, result[:error])
  end

  test 'rejects malformed json' do
    result = service('{ not json', filename: 'template.json').analyze
    refute result[:success]
    assert_match(/isn't valid JSON/, result[:error])
  end

  test 'rejects a file with no categories' do
    result = service('{"template":{"categories":{}}}').analyze
    refute result[:success]
    assert_match(/doesn't contain any template categories/, result[:error])
  end

  test 'reads a yaml export written by TemplateExportService' do
    yaml = TemplateExportService.new(@user, 'character').export_as_yaml
    result = service(yaml, filename: 'character_template.yml').analyze

    assert result[:success], result[:error]
    assert_equal 'character', result[:source_content_type]
  end

  test 'reads a csv export written by TemplateExportService' do
    csv = TemplateExportService.new(@user, 'character').export_as_csv
    result = service(csv, filename: 'character_template.csv').analyze

    assert result[:success], result[:error]
  end

  # --- merge -----------------------------------------------------------------

  test 'merge previews new categories and fields without changing anything' do
    content = JSON.generate(export_hash(
      'overview' => { 'label' => 'Overview', 'fields' => {
        'role' => { 'label' => 'Role', 'field_type' => 'text_area' },
        'quirks' => { 'label' => 'Quirks', 'field_type' => 'text_area' }
      } },
      'looks' => { 'label' => 'Looks', 'icon' => 'face', 'fields' => {
        'height' => { 'label' => 'Height', 'field_type' => 'text_area' }
      } }
    ))

    result = service(content).analyze(mode: 'merge')

    assert result[:success], result[:error]
    assert_equal ['Looks'], result[:categories_to_create]
    assert_equal 2, result[:counts][:fields_created]
    assert_equal 0, result[:counts][:fields_removed]
    assert_equal 0, result[:counts][:categories_removed]

    # Nothing was actually written
    assert_equal 1, @user.attribute_categories.where(entity_type: 'character').count
  end

  test 'merge creates missing categories and fields' do
    content = JSON.generate(export_hash(
      'looks' => { 'label' => 'Looks', 'icon' => 'face', 'fields' => {
        'height' => { 'label' => 'Height', 'field_type' => 'text_area' }
      } }
    ))

    result = service(content).import!(mode: 'merge')

    assert result[:success], result[:error]
    assert_equal 1, result[:created_categories]
    assert_equal 1, result[:created_fields]

    looks = @user.attribute_categories.find_by(entity_type: 'character', label: 'Looks')
    assert_not_nil looks
    assert_equal 'face', looks[:icon]
    assert_equal ['Height'], looks.attribute_fields.pluck(:label)
  end

  test 'merge updates an existing field instead of duplicating it' do
    content = one_category_json(
      'role' => { 'label' => 'Occupation', 'field_type' => 'text_area', 'description' => 'What they do' }
    )

    result = service(content).import!(mode: 'merge')

    assert result[:success], result[:error]
    assert_equal 0, result[:created_fields]
    assert_equal 1, result[:updated_fields]

    @role_field.reload
    assert_equal 'Occupation', @role_field.label
    assert_equal 'What they do', @role_field.description
    assert_equal 1, @category.attribute_fields.count
  end

  test 'merge matches an existing category by label when names differ' do
    content = JSON.generate(export_hash(
      'summary' => { 'label' => 'Overview', 'fields' => {} }
    ))

    result = service(content).import!(mode: 'merge')

    assert result[:success], result[:error]
    assert_equal 0, result[:created_categories]
    assert_equal 1, @user.attribute_categories.where(entity_type: 'character').count
  end

  test 'merge never deletes fields that are missing from the file' do
    content = one_category_json(
      'quirks' => { 'label' => 'Quirks', 'field_type' => 'text_area' }
    )

    result = service(content).import!(mode: 'merge')

    assert result[:success], result[:error]
    assert_equal 0, result[:removed_fields]
    assert AttributeField.exists?(@role_field.id)
  end

  # --- replace ---------------------------------------------------------------

  test 'replace removes fields that are not in the file' do
    content = one_category_json(
      'quirks' => { 'label' => 'Quirks', 'field_type' => 'text_area' }
    )

    analysis = service(content).analyze(mode: 'replace')
    assert_equal [{ category: 'Overview', field: 'Role', filled_count: 0 }], analysis[:fields_to_remove]

    result = service(content).import!(mode: 'replace')

    assert result[:success], result[:error]
    assert_equal 1, result[:removed_fields]
    assert_not AttributeField.exists?(@role_field.id)
    assert_equal ['Quirks'], @category.attribute_fields.reload.pluck(:label)
  end

  test 'replace keeps system fields it cannot recreate' do
    name_field = @category.attribute_fields.create!(
      user: @user, name: 'name', label: 'Name', field_type: 'name'
    )

    content = one_category_json(
      'quirks' => { 'label' => 'Quirks', 'field_type' => 'text_area' }
    )

    result = service(content).import!(mode: 'replace')

    assert result[:success], result[:error]
    assert AttributeField.exists?(name_field.id), 'name field should never be removed by an import'
  end

  test 'replace reports written answers that would be destroyed' do
    Attribute.create!(
      user: @user,
      attribute_field: @role_field,
      entity_type: 'Character',
      entity_id: 1,
      value: 'Blacksmith'
    )

    content = one_category_json(
      'quirks' => { 'label' => 'Quirks', 'field_type' => 'text_area' }
    )

    analysis = service(content).analyze(mode: 'replace')

    assert_equal 1, analysis[:filled_answers_at_risk]
    assert_equal 1, analysis[:affected_pages_count]
    assert analysis[:warnings].any? { |w| w.include?('Replace mode removes') }
  end

  test 'replace leaves app-managed categories alone' do
    settings = @user.attribute_categories.create!(
      entity_type: 'character', name: 'settings', label: 'Settings', icon: 'settings'
    )
    settings_field = settings.attribute_fields.create!(
      user: @user, name: 'privacy', label: 'Privacy', field_type: 'text_area'
    )

    content = one_category_json(
      'role' => { 'label' => 'Role', 'field_type' => 'text_area' }
    )

    result = service(content).import!(mode: 'replace')

    assert result[:success], result[:error]
    assert AttributeCategory.exists?(settings.id)
    assert AttributeField.exists?(settings_field.id)
  end

  # --- validation & sanitizing ----------------------------------------------

  test 'rejects an unknown mode' do
    result = service(one_category_json({})).analyze(mode: 'obliterate')
    refute result[:success]
    assert_match(/Unknown import mode/, result[:error])
  end

  test 'drops linkable types that are not real content types' do
    content = one_category_json(
      'friends' => { 'label' => 'Friends', 'field_type' => 'link', 'field_options' => {
        'linkable_types' => %w[Character NotAContentType]
      } }
    )

    assert service(content).import!(mode: 'merge')[:success]

    field = @category.attribute_fields.find_by(label: 'Friends')
    assert_equal ['Character'], field.field_options['linkable_types']
  end

  test 'coerces unknown field types to text areas' do
    content = one_category_json(
      'mystery' => { 'label' => 'Mystery', 'field_type' => 'quantum_flux' }
    )

    assert service(content).import!(mode: 'merge')[:success]
    assert_equal 'text_area', @category.attribute_fields.find_by(label: 'Mystery').field_type
  end

  test 'skips categories named after built-in sections' do
    content = JSON.generate(export_hash(
      'gallery' => { 'label' => 'Gallery', 'fields' => {} },
      'looks' => { 'label' => 'Looks', 'fields' => {} }
    ))

    result = service(content).analyze(mode: 'merge')

    assert result[:success], result[:error]
    assert_equal ['Looks'], result[:categories_to_create]
    assert result[:warnings].any? { |w| w.include?('built-in section') }
  end

  test 'warns when importing a template exported from another content type' do
    content = JSON.generate(
      { 'template' => { 'content_type' => 'location', 'categories' => {
        'geography' => { 'label' => 'Geography', 'fields' => {} }
      } } }
    )

    result = service(content).analyze(mode: 'merge')

    assert result[:success], result[:error]
    assert result[:warnings].any? { |w| w.include?('Location template') }
  end

  test 'does not import a second name field into a category that has one' do
    @category.attribute_fields.create!(
      user: @user, name: 'name', label: 'Name', field_type: 'name'
    )

    content = one_category_json(
      'title' => { 'label' => 'Title', 'field_type' => 'name' }
    )

    assert service(content).import!(mode: 'merge')[:success]

    assert_equal 1, @category.attribute_fields.reload.where(field_type: 'name').count
    assert_equal 'text_area', @category.attribute_fields.find_by(label: 'Title').field_type
  end
end
