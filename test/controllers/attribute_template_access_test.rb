require 'test_helper'

# Categories and fields make up a person's template, so only they can change them.
class AttributeTemplateAccessTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @victim   = users(:one)
    @attacker = users(:two)
    @category = AttributeCategory.create!(user: @victim, name: 'overview', label: 'Overview', entity_type: 'character')
    @field    = AttributeField.create!(user: @victim, attribute_category: @category, label: 'Description', name: 'description', field_type: 'text_area')
    sign_in @attacker
  end

  test "nobody can take over a field by creating a matching one" do
    post attribute_fields_path, params: { attribute_field: {
      user_id: @victim.id, attribute_category_id: @category.id, label: 'Description', name: 'description', field_type: 'text_area'
    }, entity_type: 'character' }, as: :json

    assert_equal @victim.id, @field.reload.user_id
  end

  test "nobody can add a field to someone else's category" do
    post attribute_fields_path, params: { attribute_field: {
      attribute_category_id: @category.id, label: 'Planted', name: 'planted', field_type: 'text_area'
    }, entity_type: 'character' }, as: :json

    assert_equal [@field.id], @category.attribute_fields.pluck(:id)
  end

  test "people can still add fields to their own categories" do
    mine = AttributeCategory.create!(user: @attacker, name: 'mine', label: 'Mine', entity_type: 'character')

    post attribute_fields_path, params: { attribute_field: {
      attribute_category_id: mine.id, label: 'New', name: 'new', field_type: 'text_area'
    } }, as: :json

    assert AttributeField.exists?(attribute_category: mine, label: 'New', user: @attacker)
  end

  test "nobody can push their field into someone else's template" do
    mine  = AttributeCategory.create!(user: @attacker, name: 'mine', label: 'Mine', entity_type: 'character')
    field = AttributeField.create!(user: @attacker, attribute_category: mine, label: 'Mine', name: 'mine', field_type: 'text_area')

    patch attribute_field_path(field), params: { attribute_field: { user_id: @victim.id, attribute_category_id: @category.id } }, as: :json

    field.reload
    assert_equal @attacker.id, field.user_id
    assert_equal mine.id, field.attribute_category_id
  end

  test "nobody can push their category into someone else's template" do
    mine = AttributeCategory.create!(user: @attacker, name: 'mine', label: 'Mine', entity_type: 'character')

    patch attribute_category_path(mine), params: { attribute_category: { user_id: @victim.id } }, as: :json

    assert_equal @attacker.id, mine.reload.user_id
  end
end
