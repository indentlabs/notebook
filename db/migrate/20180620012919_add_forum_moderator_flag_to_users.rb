class AddForumModeratorFlagToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :forum_moderator, :boolean, default: false
  end
end
