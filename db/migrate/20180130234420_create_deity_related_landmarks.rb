class CreateDeityRelatedLandmarks < ActiveRecord::Migration[4.2]
  def change
    create_table :deity_related_landmarks do |t|
      t.references :user, index: true, foreign_key: true
      t.references :deity, index: true, foreign_key: true
      t.integer :related_landmark_id

      t.timestamps null: false
    end
  end
end
