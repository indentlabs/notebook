class CreateTownFloras < ActiveRecord::Migration[4.2]
  def change
    create_table :town_floras do |t|
      t.references :user, index: true, foreign_key: true
      t.references :town, index: true, foreign_key: true
      t.references :flora, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
