class CreateLoreRelatedLores < ActiveRecord::Migration[6.0]
  def change
    create_table :lore_related_lores do |t|
      t.references :lore, null: false, foreign_key: true
      t.integer :related_lore_id
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
