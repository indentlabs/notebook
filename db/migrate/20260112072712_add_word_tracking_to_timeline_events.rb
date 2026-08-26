class AddWordTrackingToTimelineEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :timeline_events, :cached_word_count, :integer, default: 0
  end
end
