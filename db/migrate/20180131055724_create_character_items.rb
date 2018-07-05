class CreateCharacterItems < ActiveRecord::Migration[4.2]
  def change
    create_table :character_items do |t|
      t.references :user, index: true, foreign_key: true
      t.references :character, index: true, foreign_key: true
      t.references :item, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
