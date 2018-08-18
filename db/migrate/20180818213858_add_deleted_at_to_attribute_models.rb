class AddDeletedAtToAttributeModels < ActiveRecord::Migration[5.2]
  def change
    add_column :attribute_categories, :deleted_at, :datetime
    add_column :attribute_fields, :deleted_at, :datetime
    add_column :attributes, :deleted_at, :datetime
  end
end
