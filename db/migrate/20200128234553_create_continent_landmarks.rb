class CreateContinentLandmarks < ActiveRecord::Migration[6.0]
  def change
    create_table :continent_landmarks do |t|
      t.references :continent, null: false, foreign_key: true
      t.references :landmark, null: false, foreign_key: true

      t.timestamps
    end
  end
end
