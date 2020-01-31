class CreatePlanetContinents < ActiveRecord::Migration[6.0]
  def change
    create_table :planet_continents do |t|
      t.references :planet, null: false, foreign_key: true
      t.references :continent, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
