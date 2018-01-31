class CreateCharacterFriends < ActiveRecord::Migration
  def change
    create_table :character_friends do |t|
      t.references :user, index: true, foreign_key: true
      t.references :character, index: true, foreign_key: true
      t.integer :friend_id

      t.timestamps null: false
    end
  end
end
