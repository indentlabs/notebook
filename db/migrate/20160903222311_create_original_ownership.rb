class CreateOriginalOwnership < ActiveRecord::Migration
  def change
    create_table :original_ownerships do |t|
      t.integer :user_id
      t.integer :item_id
      t.integer :original_owner_id
    end
  end
end
