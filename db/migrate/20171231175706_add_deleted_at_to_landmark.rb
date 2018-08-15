class AddDeletedAtToLandmark < ActiveRecord::Migration[4.2]
  def change
    add_column :landmarks, :deleted_at, :datetime
  end
end
