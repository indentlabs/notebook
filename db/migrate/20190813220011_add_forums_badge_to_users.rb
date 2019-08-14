class AddForumsBadgeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :forums_badge_text, :string
  end
end
