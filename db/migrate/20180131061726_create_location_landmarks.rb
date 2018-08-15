class CreateLocationLandmarks < ActiveRecord::Migration[4.2]
  def change
    create_table :location_landmarks do |t|
      t.references :location, index: true, foreign_key: true
      t.references :landmark, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
