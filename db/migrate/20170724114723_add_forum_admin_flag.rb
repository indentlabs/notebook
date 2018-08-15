class AddForumAdminFlag < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :forum_admin, :string, default: false
  end
end
