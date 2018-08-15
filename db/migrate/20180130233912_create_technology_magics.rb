class CreateTechnologyMagics < ActiveRecord::Migration[4.2]
  def change
    create_table :technology_magics do |t|
      t.references :user, index: true, foreign_key: true
      t.references :technology, index: true, foreign_key: true
      t.references :magic, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
