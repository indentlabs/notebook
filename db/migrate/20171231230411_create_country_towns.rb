class CreateCountryTowns < ActiveRecord::Migration
  def change
    create_table :country_towns do |t|
      t.references :user, index: true, foreign_key: true
      t.references :country, index: true, foreign_key: true
      t.references :town, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
