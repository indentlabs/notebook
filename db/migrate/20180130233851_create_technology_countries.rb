class CreateTechnologyCountries < ActiveRecord::Migration[4.2]
  def change
    create_table :technology_countries do |t|
      t.references :user, index: true, foreign_key: true
      t.references :technology, index: true, foreign_key: true
      t.references :country, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
