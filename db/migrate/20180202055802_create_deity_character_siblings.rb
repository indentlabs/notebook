class CreateDeityCharacterSiblings < ActiveRecord::Migration[4.2]
  def change
    create_table :deity_character_siblings do |t|
      t.references :deity, index: true, foreign_key: true
      t.integer :character_sibling_id
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
