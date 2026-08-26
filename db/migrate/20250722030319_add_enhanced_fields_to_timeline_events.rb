class AddEnhancedFieldsToTimelineEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :timeline_events, :event_type, :string, default: 'general'
    add_column :timeline_events, :importance_level, :string, default: 'minor'
    add_column :timeline_events, :end_time_label, :string
    add_column :timeline_events, :status, :string, default: 'completed'
    add_column :timeline_events, :private_notes, :text
    
    add_index :timeline_events, :event_type
    add_index :timeline_events, :importance_level
    add_index :timeline_events, :status
  end
end
