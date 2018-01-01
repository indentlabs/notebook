class CreateCountryCreatures < ActiveRecord::Migration
  def change
    create_table :country_creatures do |t|
      t.references :user, index: true, foreign_key: true
      t.references :country, index: true, foreign_key: true
      t.references :creature, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
