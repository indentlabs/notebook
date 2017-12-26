class CreateCharacterLoveInterests < ActiveRecord::Migration
  def change
    create_table :character_love_interests do |t|
      t.references :user, index: true, foreign_key: true
      t.references :character, index: true, foreign_key: true
      t.integer :love_interest_id

      t.timestamps null: false
    end
  end
end
