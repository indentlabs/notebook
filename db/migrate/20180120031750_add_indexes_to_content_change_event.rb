class AddIndexesToContentChangeEvent < ActiveRecord::Migration
  def change
    add_index :content_change_events, [:content_id, :content_type]
  end
end
