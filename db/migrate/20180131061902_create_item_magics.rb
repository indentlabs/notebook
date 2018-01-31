class CreateItemMagics < ActiveRecord::Migration
  def change
    create_table :item_magics do |t|
      t.references :item, index: true, foreign_key: true
      t.references :magic, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
