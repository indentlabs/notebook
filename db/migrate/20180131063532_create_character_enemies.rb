class CreateCharacterEnemies < ActiveRecord::Migration
  def change
    create_table :character_enemies do |t|
      t.references :character, index: true, foreign_key: true
      t.integer :enemy_id
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
