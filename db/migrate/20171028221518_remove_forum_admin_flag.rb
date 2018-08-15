class RemoveForumAdminFlag < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :forum_admin
  end
end
