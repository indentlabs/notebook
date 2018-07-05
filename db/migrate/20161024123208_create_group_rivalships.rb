class CreateGroupRivalships < ActiveRecord::Migration[4.2]
  def change
    create_table :group_rivalships do |t|
      t.integer :user_id
      t.integer :group_id
      t.integer :rival_id
    end
  end
end
