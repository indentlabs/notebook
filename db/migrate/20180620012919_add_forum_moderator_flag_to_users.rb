class AddForumModeratorFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :forum_moderator, :boolean, default: false
  end
end
