class CreateAttributeCategorySuggestions < ActiveRecord::Migration[6.0]
  def change
    create_table :attribute_category_suggestions do |t|
      t.string :entity_type
      t.string :suggestion
      t.integer :weight

      t.timestamps
    end
  end
end
