class AddDeletedAtToPageFieldValues < ActiveRecord::Migration
  def change
    add_column :page_field_values, :deleted_at, :datetime
  end
end
