class CreateReligionDeities < ActiveRecord::Migration
  def change
    create_table :religion_deities do |t|
      t.references :user, index: true, foreign_key: true
      t.references :religion, index: true, foreign_key: true
      t.references :deity, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
