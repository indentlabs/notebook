class CreateArchenemyships < ActiveRecord::Migration[4.2]
  def change
    create_table :archenemyships do |t|
      t.integer :user_id
      t.integer :character_id
      t.integer :archenemy_id

      t.timestamps null: false
    end
  end
end
