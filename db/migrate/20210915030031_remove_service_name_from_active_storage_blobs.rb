class RemoveServiceNameFromActiveStorageBlobs < ActiveRecord::Migration[6.0]
  def up
    if column_exists?(:active_storage_blobs, :service_name)
      change_column_default :active_storage_blobs, :service_name, "amazon"
    end
  end

  def down
    if column_exists?(:active_storage_blobs, :service_name)
      change_column_default :active_storage_blobs, :service_name, nil
    end
  end
end
