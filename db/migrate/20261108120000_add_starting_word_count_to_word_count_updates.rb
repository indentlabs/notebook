# The count an entity had when the first change of that day was saved, measured the same way as
# word_count. Words written that day are word_count - starting_word_count.
#
# Without it, a day's words were measured against the entity's previous row, which could be weeks
# old, missing, or counted with an older counter, so a single edit could credit everything written
# since then (or the whole page) to today. Existing rows keep NULL and are still measured against
# their previous row.
class AddStartingWordCountToWordCountUpdates < ActiveRecord::Migration[6.1]
  # Adding a nullable column rewrites nothing, but it does need a brief exclusive lock on a table that
  # every edit writes to. If a long query or backup is holding the table, everything else would queue
  # behind this migration while it waits, so give up quickly instead and let the deploy be retried.
  def up
    set_lock_timeout
    add_column :word_count_updates, :starting_word_count, :integer
  end

  def down
    set_lock_timeout
    remove_column :word_count_updates, :starting_word_count
  end

  private

  def set_lock_timeout
    execute "SET LOCAL lock_timeout = '5s'" if connection.adapter_name == 'PostgreSQL'
  end
end
