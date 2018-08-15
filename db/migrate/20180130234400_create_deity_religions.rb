class CreateDeityReligions < ActiveRecord::Migration[4.2]
  def change
    create_table :deity_religions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :deity, index: true, foreign_key: true
      t.references :religion, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
