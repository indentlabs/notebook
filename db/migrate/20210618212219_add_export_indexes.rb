class AddExportIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :attributes, [:deleted_at, :user_id, :attribute_field_id, :entity_type, :entity_id], name: "all_the_export_fields"
    add_index :attributes, [:deleted_at, :user_id, :attribute_field_id, :entity_type, :entity_id, :id], name: "all_the_export_fields_with_sort"
  end
end
