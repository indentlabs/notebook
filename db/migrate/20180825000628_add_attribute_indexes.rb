class AddAttributeIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index(:attribute_categories, :user_id)

    add_index(:attribute_fields, :user_id)
    add_index(:attribute_fields, [:user_id, :attribute_category_id])
    add_index(:attribute_fields, [:user_id, :field_type])
    add_index(:attribute_fields, [:user_id, :old_column_source])

    add_index(:attributes, :user_id)
    add_index(:attributes, [:user_id, :attribute_field_id])
    add_index(:attributes, [:entity_type, :entity_id])
  end
end
