class CreatePageFields < ActiveRecord::Migration
  def change
    create_table :page_fields do |t|
      t.string :label
      t.references :page_category, index: true, foreign_key: true
      t.string :field_type, default: 'textarea'

      t.timestamps null: false
    end
  end
end
