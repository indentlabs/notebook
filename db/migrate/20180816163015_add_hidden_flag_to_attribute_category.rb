class AddHiddenFlagToAttributeCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :attribute_categories, :hidden, :boolean
  end
end
