class AddFieldOptionsToAttributeFields < ActiveRecord::Migration[6.0]
  def change
    add_column :attribute_fields, :field_options, :json
    change_column :attribute_fields, :field_options, :type, default: "{}"
  end
end
