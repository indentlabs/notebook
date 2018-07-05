class CreateDeityAbilities < ActiveRecord::Migration[4.2]
  def change
    create_table :deity_abilities do |t|
      t.references :user, index: true, foreign_key: true
      t.references :deity, index: true, foreign_key: true
      t.integer :ability_id

      t.timestamps null: false
    end
  end
end
