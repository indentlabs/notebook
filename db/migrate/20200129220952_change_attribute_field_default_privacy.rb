class ChangeAttributeFieldDefaultPrivacy < ActiveRecord::Migration[6.0]
  def change
    change_column_default(:attribute_fields, :privacy, 'public')
  end
end
