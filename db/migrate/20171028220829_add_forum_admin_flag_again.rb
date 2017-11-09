class AddForumAdminFlagAgain < ActiveRecord::Migration
  def change
    add_column :users, :forum_administrator, :boolean, null: false, default: false
  end
end
