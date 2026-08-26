class AddIndexesToNotifications < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    # Use concurrent index creation for PostgreSQL (production) to avoid locking the table
    # SQLite (development) doesn't support concurrent indexing, so we use regular indexing there
    if connection.adapter_name == 'PostgreSQL'
      add_index :notifications, :reference_code, algorithm: :concurrently, if_not_exists: true
      add_index :notifications, :viewed_at, algorithm: :concurrently, if_not_exists: true
      add_index :notifications, :created_at, algorithm: :concurrently, if_not_exists: true
      add_index :notifications, :passthrough_link, algorithm: :concurrently, if_not_exists: true
    else
      add_index :notifications, :reference_code, if_not_exists: true
      add_index :notifications, :viewed_at, if_not_exists: true
      add_index :notifications, :created_at, if_not_exists: true
      add_index :notifications, :passthrough_link, if_not_exists: true
    end
  end
end
