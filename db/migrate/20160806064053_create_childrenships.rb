class CreateChildrenships < ActiveRecord::Migration[4.2]
  def change
    create_table :childrenships do |t|
      t.integer :user_id
      t.integer :character_id
      t.integer :child_id
    end
  end
end
