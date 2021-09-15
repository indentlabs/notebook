class RemoveServiceNameFromActiveStorageBlobs < ActiveRecord::Migration[6.0]
  def up
    if column_exists?(:active_storage_blobs, :service_name)
      remove_column :active_storage_blobs, :service_name
    end
  end
end
