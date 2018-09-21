class AddAttributeFieldMigrations < ActiveRecord::Migration[5.2]
  def change
    add_index :attribute_fields, [:user_id, :attribute_category_id, :label, :hidden, :deleted], name: 'field_lookup_by_label_index'
    add_index :attribute_fields, [:user_id, :attribute_category_id, :field_type, :deleted], name: 'special_field_type_index'

    add_index :attribute_fields, [:user_id, :attribute_category_id, :label, :old_column_source, :field_type], name: 'temporary_migration_lookup_index'
  end
end
