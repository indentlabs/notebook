class CreatePlanetTowns < ActiveRecord::Migration
  def change
    create_table :planet_towns do |t|
      t.references :user, index: true, foreign_key: true
      t.references :planet, index: true, foreign_key: true
      t.references :town, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
