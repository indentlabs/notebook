require 'test_helper'
require 'minitest/mock'

class ContentControllerFieldUpdateRaceTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @character = characters(:one)
    @category = AttributeCategory.create!(
      user:        @user,
      name:        'overview',
      label:       'Overview',
      entity_type: 'character'
    )
    @field = AttributeField.create!(
      user:               @user,
      attribute_category: @category,
      label:              'Role',
      name:               'role',
      field_type:         'text_area'
    )

    sign_in @user
  end

  test "text_field_update updates the existing value when a concurrent request created it first" do
    # Another autosave for the same field won the race and created the row after our lookup missed it
    Attribute.create!(user: @user, attribute_field: @field, entity: @character, value: 'Old value')

    real_values = @field.attribute_values
    lookups = 0
    racing_values = Object.new
    racing_values.define_singleton_method(:find_or_initialize_by) do |attrs|
      lookups += 1
      lookups == 1 ? Attribute.new(attrs) : real_values.find_or_initialize_by(attrs)
    end
    @field.define_singleton_method(:attribute_values) { racing_values }

    AttributeField.stub(:find_by, @field) do
      patch text_field_update_path(@field.id),
            params: {
              entity: { entity_id: @character.id, entity_type: 'Character' },
              field:  { name: @field.id.to_s, value: 'Son of Mikhail' }
            },
            headers: { 'Accept' => 'application/json' }
    end

    assert_response :success
    assert_equal 2, lookups
    values = Attribute.where(attribute_field_id: @field.id, entity: @character)
    assert_equal 1, values.count
    assert_equal 'Son of Mikhail', values.first.value
  end

  test "text_field_update creates a value when none exists" do
    patch text_field_update_path(@field.id),
          params: {
            entity: { entity_id: @character.id, entity_type: 'Character' },
            field:  { name: @field.id.to_s, value: 'Son of Mikhail' }
          },
          headers: { 'Accept' => 'application/json' }

    assert_response :success
    values = Attribute.where(attribute_field_id: @field.id, entity: @character)
    assert_equal 1, values.count
    assert_equal 'Son of Mikhail', values.first.value
  end
end
