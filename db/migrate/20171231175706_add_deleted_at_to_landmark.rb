class AddDeletedAtToLandmark < ActiveRecord::Migration
  def change
    add_column :landmarks, :deleted_at, :datetime
  end
end
