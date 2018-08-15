class CreateMarriages < ActiveRecord::Migration[4.2]
  def change
    create_table :marriages do |t|
      t.integer :user_id
      t.integer :character_id
      t.integer :spouse_id

      t.timestamps null: false
    end
  end
end
