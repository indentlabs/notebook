class CreateLoreVariations < ActiveRecord::Migration[6.0]
  def change
    create_table :lore_variations do |t|
      t.references :lore, null: false, foreign_key: true
      t.integer :variation_id
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end
  end
end
