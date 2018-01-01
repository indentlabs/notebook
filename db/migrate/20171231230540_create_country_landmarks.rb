class CreateCountryLandmarks < ActiveRecord::Migration
  def change
    create_table :country_landmarks do |t|
      t.references :user, index: true, foreign_key: true
      t.references :country, index: true, foreign_key: true
      t.references :landmark, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
