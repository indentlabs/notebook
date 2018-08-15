class CreateGroupLeaderships < ActiveRecord::Migration[4.2]
  def change
    create_table :group_leaderships do |t|
      t.integer :user_id
      t.integer :group_id
      t.integer :leader_id
    end
  end
end
