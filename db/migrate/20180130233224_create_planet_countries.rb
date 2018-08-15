class CreatePlanetCountries < ActiveRecord::Migration[4.2]
  def change
    create_table :planet_countries do |t|
      t.references :user, index: true, foreign_key: true
      t.references :planet, index: true, foreign_key: true
      t.references :country, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
