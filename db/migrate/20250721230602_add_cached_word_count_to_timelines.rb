class AddCachedWordCountToTimelines < ActiveRecord::Migration[6.1]
  def change
    add_column :timelines, :cached_word_count, :integer, default: 0
  end
end
