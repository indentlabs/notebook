# Enforce one live (non-deleted) value per field per page. The model's uniqueness
# validation alone can't stop two concurrent autosaves from both inserting a row.
#
# Existing duplicates must be soft-deleted before this runs, or the build fails.
class AddUniqueLiveValueIndexToAttributes < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  INDEX_NAME = 'index_attributes_unique_live_value'

  def up
    options = { name: INDEX_NAME, unique: true, where: 'deleted_at IS NULL' }

    if postgres?
      # Use concurrent index creation on PostgreSQL to avoid locking the table
      options[:algorithm] = :concurrently

      # A failed concurrent build (e.g. a duplicate slipped in) leaves an INVALID index behind
      # that still slows writes; drop it so re-running the migration retries the build.
      if invalid_index_exists?
        remove_index :attributes, name: INDEX_NAME, algorithm: :concurrently
      end

      # Building over ~50M rows can outlast a configured statement_timeout
      execute 'SET statement_timeout = 0'
    end

    add_index :attributes, [:attribute_field_id, :entity_id, :entity_type], **options
  ensure
    execute 'RESET statement_timeout' if postgres?
  end

  def down
    options = { name: INDEX_NAME }
    options[:algorithm] = :concurrently if postgres?
    remove_index :attributes, **options
  end

  private

  def postgres?
    connection.adapter_name == 'PostgreSQL'
  end

  def invalid_index_exists?
    select_value(<<~SQL).present?
      SELECT 1 FROM pg_index
      JOIN pg_class ON pg_class.oid = pg_index.indexrelid
      WHERE pg_class.relname = #{connection.quote(INDEX_NAME)} AND NOT pg_index.indisvalid
    SQL
  end
end
