class CreatePageFieldValues < ActiveRecord::Migration
  def change
    create_table :page_field_values do |t|
      t.references :page_field, index: true, foreign_key: true
      t.integer :page_id
      t.text :value
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
