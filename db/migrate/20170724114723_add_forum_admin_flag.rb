class AddForumAdminFlag < ActiveRecord::Migration
  def change
    add_column :users, :forum_admin, :string, default: false
  end
end
