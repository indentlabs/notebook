class AddPositionToAttributeField < ActiveRecord::Migration[5.2]
  def change
    add_column :attribute_categories, :position, :int
    add_column :attribute_fields, :position, :int
  end
end
