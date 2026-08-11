require 'test_helper'

class HasAttributesPreloadTest < ActiveSupport::TestCase
  def setup
    @user = User.first
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
    @characters = 3.times.map do |i|
      Character.create!(user: @user, name: "Character #{i}")
    end
    @characters.each_with_index do |character, i|
      Attribute.create!(
        user:            @user,
        attribute_field: @field,
        entity:          character,
        value:           "Role #{i}"
      )
    end
  end

  test "description_attribute_label reflects the label each description reads" do
    assert_equal 'Role', Character.description_attribute_label
    assert_equal 'Summary', Lore.description_attribute_label
    assert_equal 'Description', Location.description_attribute_label
  end

  test "preload_overview_field_values returns the same values as per-record lookups" do
    expected = Character.where(id: @characters.map(&:id)).order(:id).map do |character|
      character.overview_field_value('Role')
    end

    preloaded = Character.where(id: @characters.map(&:id)).order(:id).to_a
    Character.preload_overview_field_values(preloaded)

    assert_equal expected, preloaded.map(&:description)
    assert_equal ['Role 0', 'Role 1', 'Role 2'], preloaded.map(&:description)
  end

  test "preloaded records don't query when reading description" do
    records = Character.where(id: @characters.map(&:id)).to_a
    Character.preload_overview_field_values(records)

    queries = count_queries { records.each(&:description) }
    assert_equal 0, queries
  end

  test "overview_field_value memoizes repeated calls on the same instance" do
    character = @characters.first.reload

    first_call_queries = count_queries { character.overview_field_value('Role') }
    assert first_call_queries.positive?

    repeat_call_queries = count_queries { 3.times { character.overview_field_value('Role') } }
    assert_equal 0, repeat_call_queries
  end

  test "preload handles records with no matching field" do
    records = Character.where(id: @characters.map(&:id)).to_a
    Character.preload_overview_field_values(records, 'Nonexistent Label')

    queries = count_queries { records.each { |r| r.overview_field_value('Nonexistent Label') } }
    assert_equal 0, queries
    assert records.all? { |r| r.overview_field_value('Nonexistent Label').nil? }
  end

  private

  def count_queries(&block)
    count = 0
    counter = lambda do |_name, _start, _finish, _id, payload|
      count += 1 unless payload[:name].in?(['SCHEMA', 'TRANSACTION']) || payload[:sql].blank?
    end
    ActiveSupport::Notifications.subscribed(counter, 'sql.active_record', &block)
    count
  end
end
