class CreateDeityFloras < ActiveRecord::Migration[4.2]
  def change
    create_table :deity_floras do |t|
      t.references :user, index: true, foreign_key: true
      t.references :deity, index: true, foreign_key: true
      t.references :flora, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
