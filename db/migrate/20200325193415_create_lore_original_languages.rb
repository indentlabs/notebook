class CreateLoreOriginalLanguages < ActiveRecord::Migration[6.0]
  def change
    create_table :lore_original_languages do |t|
      t.references :lore, null: false, foreign_key: true
      t.integer :original_language_id
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
