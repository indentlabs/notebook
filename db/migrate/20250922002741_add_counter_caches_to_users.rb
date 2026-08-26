class AddCounterCachesToUsers < ActiveRecord::Migration[6.1]
  def change
    # Add counter cache columns for followers and following
    add_column :users, :followers_count, :integer, default: 0, null: false
    add_column :users, :following_count, :integer, default: 0, null: false
    
    # Add indexes for the counter cache columns
    add_index :users, :followers_count
    add_index :users, :following_count
    
    # Populate the counter caches with existing data
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE users 
          SET followers_count = (
            SELECT COUNT(*) 
            FROM user_followings 
            WHERE followed_user_id = users.id
          )
        SQL
        
        execute <<-SQL
          UPDATE users
          SET following_count = (
            SELECT COUNT(*)
            FROM user_followings
            WHERE user_id = users.id
          )
        SQL
      end
    end
  end
end