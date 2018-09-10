class AddMoreAttributeIndices < ActiveRecord::Migration[5.2]
  def change
    add_index(:attributes, [:deleted_at, :attribute_field_id, :entity_type, :entity_id], name: 'deleted_at__attribute_field_id__entity_type_and_id')
    add_index(:attribute_fields, [:deleted_at, :attribute_category_id], name: 'deleted_at__attribute_category_id')
  end
end
