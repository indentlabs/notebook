class CreateCharacterCompanions < ActiveRecord::Migration[4.2]
  def change
    create_table :character_companions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :character, index: true, foreign_key: true
      t.integer :companion_id

      t.timestamps null: false
    end
  end
end
