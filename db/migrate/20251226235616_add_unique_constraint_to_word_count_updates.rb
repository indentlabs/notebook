class AddUniqueConstraintToWordCountUpdates < ActiveRecord::Migration[6.1]
  def up
    # First, add a non-unique index to speed up the deduplication queries
    add_index :word_count_updates,
              [:user_id, :entity_type, :entity_id, :for_date],
              name: 'index_word_count_updates_for_dedup'

    # Delete duplicates in batches using EXISTS (much faster than NOT IN)
    # Keeps the record with the highest ID for each unique combination
    total_deleted = 0
    loop do
      result = execute(<<-SQL)
        DELETE FROM word_count_updates
        WHERE id IN (
          SELECT w1.id
          FROM word_count_updates w1
          WHERE EXISTS (
            SELECT 1 FROM word_count_updates w2
            WHERE w2.user_id = w1.user_id
              AND w2.entity_type = w1.entity_type
              AND w2.entity_id = w1.entity_id
              AND w2.for_date = w1.for_date
              AND w2.id > w1.id
          )
          LIMIT 10000
        )
      SQL
      deleted = result.cmd_tuples
      total_deleted += deleted
      puts "Deleted #{deleted} duplicate rows (total: #{total_deleted})"
      break if deleted == 0
      sleep 0.1 # Brief pause to reduce DB load
    end

    # Remove the temporary dedup index
    remove_index :word_count_updates, name: 'index_word_count_updates_for_dedup'

    # Add unique constraint to prevent future duplicates
    add_index :word_count_updates,
              [:user_id, :entity_type, :entity_id, :for_date],
              unique: true,
              name: 'index_word_count_updates_unique_per_entity_per_date'

    # Add index for efficient date-based lookups per user
    add_index :word_count_updates,
              [:user_id, :for_date],
              name: 'index_word_count_updates_on_user_id_and_for_date'
  end

  def down
    remove_index :word_count_updates, name: 'index_word_count_updates_on_user_id_and_for_date'
    remove_index :word_count_updates, name: 'index_word_count_updates_unique_per_entity_per_date'
  end
end
