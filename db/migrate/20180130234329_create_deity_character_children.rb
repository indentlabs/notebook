class CreateDeityCharacterChildren < ActiveRecord::Migration[4.2]
  def change
    create_table :deity_character_children do |t|
      t.references :user, index: true, foreign_key: true
      t.references :deity, index: true, foreign_key: true
      t.integer :character_child_id

      t.timestamps null: false
    end
  end
end
