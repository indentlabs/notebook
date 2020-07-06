class CreateTimelineEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :timeline_events do |t|
      t.references :timeline, null: false, foreign_key: true
      t.string :time_label
      t.string :title
      t.string :description
      t.string :notes
      t.integer :position

      t.timestamps
    end
  end
end
