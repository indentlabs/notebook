class CreateKeyItemships < ActiveRecord::Migration[4.2]
  def change
    create_table :key_itemships do |t|
      t.integer :user_id
      t.integer :group_id
      t.integer :key_item_id
    end
  end
end
