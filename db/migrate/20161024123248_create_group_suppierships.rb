class CreateGroupSuppierships < ActiveRecord::Migration[4.2]
  def change
    create_table :group_supplierships do |t|
      t.integer :user_id
      t.integer :group_id
      t.integer :supplier_id
    end
  end
end
