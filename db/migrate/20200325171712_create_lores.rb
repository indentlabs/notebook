class CreateLores < ActiveRecord::Migration[6.0]
  def change
    create_table :lores do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true
      t.references :universe, null: false, foreign_key: true
      t.datetime :deleted_at
      t.datetime :archived_at
      t.string :privacy
      t.boolean :favorite
      t.string :page_type, default: 'Lore'

      t.timestamps
    end
  end
end
