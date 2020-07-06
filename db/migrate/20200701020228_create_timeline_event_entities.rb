class CreateTimelineEventEntities < ActiveRecord::Migration[6.0]
  def change
    create_table :timeline_event_entities do |t|
      t.references :entity, polymorphic: true, null: false
      t.references :timeline_event, null: false, foreign_key: true
      t.string :notes

      t.timestamps
    end
  end
end
