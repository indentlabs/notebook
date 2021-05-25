class AddFieldOptionsToAttributeFields < ActiveRecord::Migration[6.0]
  def change
    add_column :attribute_fields, :field_options, :json
  end
end
