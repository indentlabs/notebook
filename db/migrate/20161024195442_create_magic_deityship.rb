class CreateMagicDeityship < ActiveRecord::Migration
  def change
    create_table :magic_deityships do |t|
      t.integer :user_id
      t.integer :magic_id
      t.integer :deity_id
    end
  end
end
