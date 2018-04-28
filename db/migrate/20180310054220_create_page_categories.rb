class CreatePageCategories < ActiveRecord::Migration
  def change
    create_table :page_categories do |t|
      t.string :label
      t.references :universe, index: true, foreign_key: true
      t.string :content_type
      t.string :icon

      t.timestamps null: false
    end
  end
end
