class CreateCountryGovernments < ActiveRecord::Migration
  def change
    create_table :country_governments do |t|
      t.references :country, index: true, foreign_key: true
      t.references :government, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
