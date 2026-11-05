class RemoveRedundantUserFollowingsIndexes < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  # Every follow lookup the app makes by followed_user_id is of live follows, which the two indexes added just
  # before this cover: (followed_user_id, id) for follower lists and (followed_user_id, user_id) for "does X
  # follow Y". These two older indexes only slow down every follow and unfollow now. The user_id index stays:
  # following lists use it, and the foreign key to users needs it.
  REDUNDANT_INDEXES = {
    'index_user_followings_on_followed_user_id' => [:followed_user_id],
    'index_user_followings_on_followed_and_user' => [:followed_user_id, :user_id]
  }.freeze

  def up
    without_statement_timeout do
      REDUNDANT_INDEXES.each_key do |name|
        remove_index :user_followings, name: name, if_exists: true, **concurrently
      end
    end
  end

  def down
    without_statement_timeout do
      REDUNDANT_INDEXES.each do |name, columns|
        add_index :user_followings, columns, name: name, if_not_exists: true, **concurrently
      end
    end
  end

  private

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
