class AddUniqueIndexToWordCountUpdates < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    # Use concurrent index creation for PostgreSQL (production) to avoid locking the table
    # SQLite (development) doesn't support concurrent indexing, so we use regular indexing there
    if connection.adapter_name == 'PostgreSQL'
      add_index :word_count_updates,
                [:entity_type, :entity_id, :for_date],
                unique: true,
                name: 'index_word_count_updates_unique_entity_date',
                algorithm: :concurrently,
                if_not_exists: true
    else
      add_index :word_count_updates,
                [:entity_type, :entity_id, :for_date],
                unique: true,
                name: 'index_word_count_updates_unique_entity_date',
                if_not_exists: true
    end
  end

  def down
    if connection.adapter_name == 'PostgreSQL'
      remove_index :word_count_updates,
                   name: 'index_word_count_updates_unique_entity_date',
                   algorithm: :concurrently,
                   if_exists: true
    else
      remove_index :word_count_updates,
                   name: 'index_word_count_updates_unique_entity_date',
                   if_exists: true
    end
  end
end
