class CreateTechnologyTowns < ActiveRecord::Migration
  def change
    create_table :technology_towns do |t|
      t.references :user, index: true, foreign_key: true
      t.references :technology, index: true, foreign_key: true
      t.references :town, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
