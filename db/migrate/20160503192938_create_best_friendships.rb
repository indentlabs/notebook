class CreateBestFriendships < ActiveRecord::Migration[4.2]
  def change
    create_table :best_friendships do |t|
      t.integer :user_id
      t.integer :character_id
      t.integer :best_friend_id

      t.timestamps null: false
    end
  end
end
