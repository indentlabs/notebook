class CreateCharacterMagics < ActiveRecord::Migration[4.2]
  def change
    create_table :character_magics do |t|
      t.references :character, index: true, foreign_key: true
      t.references :magic, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
