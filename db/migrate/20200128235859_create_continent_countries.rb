class CreateContinentCountries < ActiveRecord::Migration[6.0]
  def change
    create_table :continent_countries do |t|
      t.references :continent, null: false, foreign_key: true
      t.references :country, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
