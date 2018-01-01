class CreateLandmarkFloras < ActiveRecord::Migration
  def change
    create_table :landmark_floras do |t|
      t.references :user, index: true, foreign_key: true
      t.references :landmark, index: true, foreign_key: true
      t.references :flora, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
