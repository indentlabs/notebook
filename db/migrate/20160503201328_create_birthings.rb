class CreateBirthings < ActiveRecord::Migration[4.2]
  def change
    create_table :birthings do |t|
      t.integer :character_id
      t.integer :birthplace_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
