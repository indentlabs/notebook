class AddFollowedUserIdAndIdIndexToUserFollowings < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  # The followers page lists a user's newest followers first (ORDER BY id DESC). With only an index on
  # followed_user_id, Postgres has to read and sort every follow of that user to find a page of them;
  # this index lets it walk straight to the page instead.
  def up
    if connection.adapter_name == 'PostgreSQL'
      add_index :user_followings,
                [:followed_user_id, :id],
                name: 'index_user_followings_on_followed_user_id_and_id',
                algorithm: :concurrently,
                if_not_exists: true
    else
      add_index :user_followings,
                [:followed_user_id, :id],
                name: 'index_user_followings_on_followed_user_id_and_id',
                if_not_exists: true
    end
  end

  def down
    if connection.adapter_name == 'PostgreSQL'
      remove_index :user_followings,
                   name: 'index_user_followings_on_followed_user_id_and_id',
                   algorithm: :concurrently,
                   if_exists: true
    else
      remove_index :user_followings,
                   name: 'index_user_followings_on_followed_user_id_and_id',
                   if_exists: true
    end
  end
end
