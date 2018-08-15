class CreateOwnerships < ActiveRecord::Migration[4.2]
  def change
    create_table :ownerships do |t|
      t.integer :character_id
      t.integer :item_id
      t.integer :user_id
      t.boolean :favorite

      t.timestamps null: false
    end
  end
end
