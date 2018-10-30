class AddMoreIndicesToTables < ActiveRecord::Migration[5.2]
  def change
    add_index :users, [:id, :deleted_at]

    add_index :characters, [:id, :deleted_at]
    add_index :countries, [:id, :deleted_at]
    add_index :creatures, [:id, :deleted_at]
    add_index :deities, [:id, :deleted_at]
    add_index :floras, [:id, :deleted_at]
    add_index :governments, [:id, :deleted_at]
    add_index :groups, [:id, :deleted_at]
    add_index :items, [:id, :deleted_at]
    add_index :landmarks, [:id, :deleted_at]
    add_index :languages, [:id, :deleted_at]
    add_index :locations, [:id, :deleted_at]
    add_index :magics, [:id, :deleted_at]
    add_index :planets, [:id, :deleted_at]
    add_index :races, [:id, :deleted_at]
    add_index :religions, [:id, :deleted_at]
    add_index :scenes, [:id, :deleted_at]
    add_index :technologies, [:id, :deleted_at]
    add_index :towns, [:id, :deleted_at]
    add_index :universes, [:id, :deleted_at]

    add_index :attribute_categories, [:entity_type, :name, :label, :user_id, :created_at], name: 'entity_type_name_label_user_id_created_at'
    add_index :attribute_categories, [:deleted_at, :user_id, :entity_type, :hidden], name: 'entity_type_name_label_user_id_deleted_at'
    add_index :attribute_categories, [:deleted_at, :user_id, :entity_type, :hidden, :created_at], name: 'entity_type_name_label_user_id_created_at_deleted_at'

    add_index :attribute_fields, [:attribute_category_id, :label, :old_column_source, :user_id, :field_type], name: 'attribute_fields_aci_label_ocs_ui_ft'
    add_index :attribute_fields, [:attribute_category_id, :label, :old_column_source, :field_type], name: 'attribute_fields_aci_label_ocs_ft'
    add_index :attribute_fields, [:deleted_at, :user_id, :attribute_category_id, :label, :hidden], name: 'attribute_fields_da_ui_aci_l_h'
    add_index :attribute_fields, [:attribute_category_id, :deleted_at]

    add_index :attributes, [:attribute_field_id, :deleted_at]
    add_index :attributes, [:attribute_field_id, :deleted_at, :entity_id, :entity_type], name: 'attributes_afi_deleted_at_entity_id_entity_type'
  end
end
