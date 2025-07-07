class AddNameIndexesToContentTypes < ActiveRecord::Migration[6.1]
  def up
    # Add optimized name search indexes for all content types
    content_tables = %w[
      universes characters locations items buildings conditions continents countries creatures deities
      floras foods governments groups jobs landmarks languages lores magics planets races religions
      scenes schools sports technologies towns traditions vehicles
    ]
    
    content_tables.each do |table_name|
      next unless table_exists?(table_name)
      next unless column_exists?(table_name, :name)
      next unless column_exists?(table_name, :user_id)
      
      if ActiveRecord::Base.connection.adapter_name.downcase.include?('postgresql')
        # PostgreSQL: Add trigram index for fast LIKE searches
        begin
          execute "CREATE EXTENSION IF NOT EXISTS pg_trgm"
          add_index table_name, [:user_id, :name], name: "idx_#{table_name}_user_name"
          add_index table_name, :name, using: :gin, opclass: {name: :gin_trgm_ops}, name: "idx_#{table_name}_name_trgm"
        rescue => e
          Rails.logger.warn "Could not add trigram index to #{table_name}: #{e.message}"
          # Fallback to regular index
          add_index table_name, [:user_id, :name], name: "idx_#{table_name}_user_name" unless index_exists?(table_name, [:user_id, :name])
        end
      else
        # SQLite and other databases: Regular indexes
        add_index table_name, [:user_id, :name], name: "idx_#{table_name}_user_name" unless index_exists?(table_name, [:user_id, :name])
      end
    end
  end

  def down
    content_tables = %w[
      universes characters locations items buildings conditions continents countries creatures deities
      floras foods governments groups jobs landmarks languages lores magics planets races religions
      scenes schools sports technologies towns traditions vehicles
    ]
    
    content_tables.each do |table_name|
      next unless table_exists?(table_name)
      
      remove_index table_name, name: "idx_#{table_name}_user_name" if index_exists?(table_name, [:user_id, :name], name: "idx_#{table_name}_user_name")
      remove_index table_name, name: "idx_#{table_name}_name_trgm" if index_exists?(table_name, :name, name: "idx_#{table_name}_name_trgm")
    end
  end
end
