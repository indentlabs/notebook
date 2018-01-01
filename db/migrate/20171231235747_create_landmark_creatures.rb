class CreateLandmarkCreatures < ActiveRecord::Migration
  def change
    create_table :landmark_creatures do |t|
      t.references :user, index: true, foreign_key: true
      t.references :landmark, index: true, foreign_key: true
      t.references :creature, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
