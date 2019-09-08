class AddDocumentAnalysisIndices < ActiveRecord::Migration[5.2]
  def change
    add_index :documents, [:universe_id, :deleted_at]

    add_index :attribute_categories, [:entity_type, :name, :user_id]

    add_index :attribute_fields, [:attribute_category_id, :old_column_source, :user_id, :field_type], name: :attribute_fields_aci_ocs_ui_ft

    add_index :attributes, [:user_id, :deleted_at]
    add_index :attributes, [:attribute_field_id, :user_id, :entity_type, :entity_id, :deleted_at], name: :attributes_afi_ui_et_ei_da
  end
end
