class CreateDeityships < ActiveRecord::Migration[4.2]
  def change
    create_table :deityships do |t|
      t.integer :religion_id
      t.integer :deity_id
      t.integer :user_id
    end
  end
end
