class CreateGroupMemberships < ActiveRecord::Migration[4.2]
  def change
    create_table :group_memberships do |t|
      t.integer :user_id
      t.integer :group_id
      t.integer :member_id
    end
  end
end
