class CreatePastOwnership < ActiveRecord::Migration
  def change
    create_table :past_ownerships do |t|
      t.integer :user_id
      t.integer :item_id
      t.integer :past_owner_id
    end
  end
end
