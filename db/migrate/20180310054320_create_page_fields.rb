class CreatePageFields < ActiveRecord::Migration
  def change
    create_table :page_fields do |t|
      t.string :label
      t.references :user, index: true, foreign_key: true
      t.references :page_category, index: true, foreign_key: true
      t.string :field_type
      t.text :value

      t.timestamps null: false
    end
  end
end
