class AddHiddenFlagToAttributeField < ActiveRecord::Migration[5.2]
  def change
    add_column :attribute_fields, :hidden, :boolean
  end
end
