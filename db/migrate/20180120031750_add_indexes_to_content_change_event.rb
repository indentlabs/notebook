class AddIndexesToContentChangeEvent < ActiveRecord::Migration[4.2]
  def change
    add_index :content_change_events, [:content_id, :content_type]
  end
end
