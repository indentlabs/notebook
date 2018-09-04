class AddOldColumnSourceToAttributeField < ActiveRecord::Migration[5.2]
  def change
    add_column :attribute_fields, :old_column_source, :string
  end
end
