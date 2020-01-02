class AddHiddenDefaultForCategoriesAndFields < ActiveRecord::Migration[6.0]
  def up
    change_column :attribute_categories, :hidden, :boolean, :default => false
    change_column :attribute_fields,     :hidden, :boolean, :default => false
  end
end
