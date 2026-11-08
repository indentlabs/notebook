# The count an entity had when the first change of that day was saved, measured the same way as
# word_count. Words written that day are word_count - starting_word_count.
#
# Without it, a day's words were measured against the entity's previous row, which could be weeks
# old, missing, or counted with an older counter, so a single edit could credit everything written
# since then (or the whole page) to today. Existing rows keep NULL and are still measured against
# their previous row.
class AddStartingWordCountToWordCountUpdates < ActiveRecord::Migration[6.1]
  def change
    add_column :word_count_updates, :starting_word_count, :integer
  end
end
