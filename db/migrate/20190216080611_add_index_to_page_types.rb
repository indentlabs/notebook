class AddIndexToPageTypes < ActiveRecord::Migration[5.2]
  def change
    add_index(:page_tags, [:user_id, :page_type])
  end
end
