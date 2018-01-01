class CreateLandmarkCountries < ActiveRecord::Migration
  def change
    create_table :landmark_countries do |t|
      t.references :user, index: true, foreign_key: true
      t.references :landmark, index: true, foreign_key: true
      t.references :country, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
