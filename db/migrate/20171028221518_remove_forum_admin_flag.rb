class RemoveForumAdminFlag < ActiveRecord::Migration
  def change
    remove_column :users, :forum_admin
  end
end
