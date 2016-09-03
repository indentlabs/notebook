class CreateCurrentOwnership < ActiveRecord::Migration
  def change
    create_table :current_ownerships do |t|
      t.integer :user_id
      t.integer :item_id
      t.integer :current_owner_id
    end
  end
end
