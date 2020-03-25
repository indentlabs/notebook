class CreateLoreBuildings < ActiveRecord::Migration[6.0]
  def change
    create_table :lore_buildings do |t|
      t.references :lore, null: false, foreign_key: true
      t.references :building, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
