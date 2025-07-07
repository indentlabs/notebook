class AddSearchIndexToAttributes < ActiveRecord::Migration[6.1]
  def up
    # Add database-specific search index for text search performance
    if ActiveRecord::Base.connection.adapter_name.downcase.include?('postgresql')
      # PostgreSQL: Use GIN index with lower() function for case-insensitive search
      add_index :attributes, 'LOWER(value)', name: 'index_attributes_on_lower_value', using: :gin
      
      # Also add a btree index for exact matches and prefix searches
      add_index :attributes, [:user_id, :value], name: 'index_attributes_on_user_id_and_value'
    else
      # SQLite and other databases: Use regular index on value column
      # SQLite is case-insensitive by default for LIKE operations
      add_index :attributes, [:user_id, :value], name: 'index_attributes_on_user_id_and_value'
    end
  end

  def down
    # Remove indexes regardless of database type
    remove_index :attributes, name: 'index_attributes_on_lower_value' if index_exists?(:attributes, :value, name: 'index_attributes_on_lower_value')
    remove_index :attributes, name: 'index_attributes_on_user_id_and_value' if index_exists?(:attributes, [:user_id, :value], name: 'index_attributes_on_user_id_and_value')
  end
end
