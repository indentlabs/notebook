class AddForumAdminFlagAgain < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :forum_administrator, :boolean, null: false, default: false
  end
end
