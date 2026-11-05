class AddFollowedUserIdAndIdIndexToUserFollowings < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  INDEX_NAME = 'index_user_followings_on_live_followed_user_id_and_id'.freeze

  # Follower lists show a user's newest followers first (ORDER BY id DESC). With only an index on
  # followed_user_id, Postgres has to read and sort every follow of that user to find one page of them;
  # this lets it walk straight to the page. Only live follows are indexed because those are the only
  # ones the app reads (UserFollowing is paranoid), which also keeps the index smaller.
  def up
    without_statement_timeout do
      # A failed concurrent build leaves an invalid index behind that would satisfy if_not_exists
      remove_index :user_followings, name: INDEX_NAME, if_exists: true, **concurrently
      add_index :user_followings, [:followed_user_id, :id], name: INDEX_NAME, where: 'deleted_at IS NULL', **concurrently
    end
  end

  def down
    without_statement_timeout do
      remove_index :user_followings, name: INDEX_NAME, if_exists: true, **concurrently
    end
  end

  private

  # Builds without blocking follows and signups (every signup follows user 5) while it runs
  def concurrently
    postgres? ? { algorithm: :concurrently } : {}
  end

  # Like the attributes unique index migration: a build over millions of rows can outlast a configured statement_timeout
  def without_statement_timeout
    execute 'SET statement_timeout = 0' if postgres?
    yield
  ensure
    execute 'RESET statement_timeout' if postgres?
  end

  def postgres?
    connection.adapter_name == 'PostgreSQL'
  end
end
