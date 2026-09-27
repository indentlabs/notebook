# The community stats page (CommunityStatsService) aggregates word counts
# across all users by date. Every existing index leads with user_id or
# entity_type, so date-range scans would read the whole table.
class AddForDateIndexToWordCountUpdates < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    options = connection.index_algorithms.key?(:concurrently) ? { algorithm: :concurrently } : {}
    add_index :word_count_updates, [:for_date, :user_id], name: 'index_word_count_updates_on_for_date_and_user_id', **options
  end
end
