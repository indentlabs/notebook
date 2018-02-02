class CreateCharacterBirthtowns < ActiveRecord::Migration
  def change
    create_table :character_birthtowns do |t|
      t.references :user, index: true, foreign_key: true
      t.references :character, index: true, foreign_key: true
      t.integer :birthtown_id

      t.timestamps null: false
    end
  end
end
