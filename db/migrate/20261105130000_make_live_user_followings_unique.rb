class MakeLiveUserFollowingsUnique < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  INDEX_NAME = 'index_user_followings_on_live_followed_user_id_and_user_id'.freeze
  BUILD_ATTEMPTS = 3
  COUNTER_BATCH_SIZE = 1_000

  # Nothing stopped someone following the same person twice (a double-clicked follow button, or the
  # one-off make_everyone_follow_andrew task re-following people who already did), so the follower
  # associations had to SELECT DISTINCT, which made every follower list read all of a user's follows.
  # This removes the duplicates and makes the database refuse new ones.
  #
  # Duplicates are soft-deleted, like an unfollow, keeping the oldest follow of each pair so its date
  # survives. Soft-deleted follows don't count towards uniqueness, so following someone again after
  # unfollowing them still works.
  def up
    without_statement_timeout do
      affected_user_ids = Set.new
      attempts = 0

      begin
        attempts += 1
        # A failed concurrent build (e.g. a duplicate slipped in) leaves an invalid index behind that still
        # slows writes and would satisfy an if_not_exists check, so start each attempt without it.
        remove_index :user_followings, name: INDEX_NAME, if_exists: true, **concurrently
        affected_user_ids.merge(soft_delete_duplicate_follows)

        add_index :user_followings, [:followed_user_id, :user_id],
                  name: INDEX_NAME, unique: true, where: 'deleted_at IS NULL', **concurrently
      rescue ActiveRecord::RecordNotUnique
        # Someone followed the same person twice between the cleanup and the build. Clean up again.
        retry if attempts < BUILD_ATTEMPTS
        raise
      end

      # Each duplicate was counted in both users' counter caches
      reset_follow_counters(affected_user_ids.to_a)
    end
  end

  # The duplicates stay soft-deleted: they were never meant to exist, and the follows they duplicated are still live
  def down
    without_statement_timeout do
      remove_index :user_followings, name: INDEX_NAME, if_exists: true, **concurrently
    end
  end

  private

  # Returns the ids of every user on either side of a duplicate follow
  def soft_delete_duplicate_follows
    duplicate_follows = <<~SQL.squish
      user_followings.deleted_at IS NULL
      AND EXISTS (
        SELECT 1 FROM user_followings older
        WHERE older.followed_user_id = user_followings.followed_user_id
          AND older.user_id = user_followings.user_id
          AND older.deleted_at IS NULL
          AND older.id < user_followings.id
      )
    SQL

    pairs = select_rows("SELECT DISTINCT user_id, followed_user_id FROM user_followings WHERE #{duplicate_follows}")
    return [] if pairs.empty?

    now = connection.quote(Time.current)
    removed = exec_update("UPDATE user_followings SET deleted_at = #{now}, updated_at = #{now} WHERE #{duplicate_follows}")
    say "Soft-deleted #{removed} duplicate follows across #{pairs.size} pairs of users"

    pairs.flatten.map(&:to_i).uniq
  end

  def reset_follow_counters(user_ids)
    user_ids.each_slice(COUNTER_BATCH_SIZE) do |ids|
      execute <<~SQL.squish
        UPDATE users SET
          following_count = (SELECT COUNT(*) FROM user_followings f WHERE f.user_id = users.id AND f.deleted_at IS NULL),
          followers_count = (SELECT COUNT(*) FROM user_followings f WHERE f.followed_user_id = users.id AND f.deleted_at IS NULL)
        WHERE users.id IN (#{ids.join(',')})
      SQL
    end
  end

  # Builds and drops without blocking follows and signups (every signup follows user 5) while it runs
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
