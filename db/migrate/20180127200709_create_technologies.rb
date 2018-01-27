class CreateTechnologies < ActiveRecord::Migration
  def change
    create_table :technologies do |t|
      t.string :name
      t.string :description
      t.string :other_names
      t.string :materials
      t.string :manufacturing_process
      t.string :sales_process
      t.string :cost
      t.string :rarity
      t.string :purpose
      t.string :how_it_works
      t.string :resources_used
      t.string :physical_description
      t.string :size
      t.string :weight
      t.string :colors
      t.string :notes
      t.string :private_notes
      t.string :privacy
      t.references :user, index: true, foreign_key: true
      t.references :universe, index: true, foreign_key: true
      t.datetime :deleted_at

      t.timestamps null: false
    end
  end
end
