# Devise looks users up by confirmation_token when they click the link in their email.
class AddConfirmationTokenIndexToUsers < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    options = { unique: true, name: 'index_users_on_confirmation_token', if_not_exists: true }
    options[:algorithm] = :concurrently if connection.adapter_name == 'PostgreSQL'
    add_index :users, :confirmation_token, **options
  end

  def down
    options = { name: 'index_users_on_confirmation_token', if_exists: true }
    options[:algorithm] = :concurrently if connection.adapter_name == 'PostgreSQL'
    remove_index :users, **options
  end
end
