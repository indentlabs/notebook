class CreateCountryLocations < ActiveRecord::Migration[4.2]
  def change
    create_table :country_locations do |t|
      t.references :user, index: true, foreign_key: true
      t.references :country, index: true, foreign_key: true
      t.references :location, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
