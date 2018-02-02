class CreateCharacterTechnologies < ActiveRecord::Migration
  def change
    create_table :character_technologies do |t|
      t.references :user, index: true, foreign_key: true
      t.references :character, index: true, foreign_key: true
      t.references :technology, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
