class CreateCountryBorderingCountries < ActiveRecord::Migration[6.0]
  def change
    create_table :country_bordering_countries do |t|
      t.references :country, null: false, foreign_key: true
      t.integer :bordering_country_id, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
