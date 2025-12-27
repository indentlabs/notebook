class AddUniqueConstraintToWordCountUpdates < ActiveRecord::Migration[6.1]
  def up
    # First, remove duplicate records keeping only the one with the highest word_count
    # for each (user_id, entity_type, entity_id, for_date) combination
    execute <<-SQL
      DELETE FROM word_count_updates
      WHERE id NOT IN (
        SELECT MAX(id)
        FROM word_count_updates
        GROUP BY user_id, entity_type, entity_id, for_date
      )
    SQL

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
