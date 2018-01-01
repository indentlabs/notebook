class CreateCountryReligions < ActiveRecord::Migration
  def change
    create_table :country_religions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :country, index: true, foreign_key: true
      t.references :religion, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
