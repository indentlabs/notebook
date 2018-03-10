class CreatePageCategories < ActiveRecord::Migration
  def change
    create_table :page_categories do |t|
      t.string :label
      t.references :user, index: true, foreign_key: true
      t.references :universe, index: true, foreign_key: true
      t.string :content_type

      t.timestamps null: false
    end
  end
end
