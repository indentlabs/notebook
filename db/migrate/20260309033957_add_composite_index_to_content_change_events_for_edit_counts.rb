class AddCompositeIndexToContentChangeEventsForEditCounts < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    options = {
      name: 'index_cce_on_user_content_type_content_id'
    }

    # Use concurrent index creation on PostgreSQL to avoid table locks
    if connection.adapter_name == 'PostgreSQL'
      options[:algorithm] = :concurrently
    end

    add_index :content_change_events,
              [:user_id, :content_type, :content_id],
              **options
  end
end
