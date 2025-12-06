class AddPerformanceIndexesForUserProfiles < ActiveRecord::Migration[6.1]
  def change
    # Add composite indexes for content_page_shares
    add_index :content_page_shares, [:user_id, :created_at, :privacy], 
              name: 'index_content_page_shares_on_user_created_privacy'
    
    # Add composite index for page_tags
    add_index :page_tags, [:user_id, :slug], 
              name: 'index_page_tags_on_user_and_slug'
    
    # Add index for reverse follower lookups
    add_index :user_followings, [:followed_user_id, :user_id], 
              name: 'index_user_followings_on_followed_and_user'
    
    # Add index for reverse blocking lookups  
    add_index :user_blockings, [:blocked_user_id, :user_id],
              name: 'index_user_blockings_on_blocked_and_user'
    
    # Add composite indexes for basil_commissions
    add_index :basil_commissions, [:user_id, :saved_at],
              name: 'index_basil_commissions_on_user_and_saved'
    
    # Add composite indexes for image_uploads
    add_index :image_uploads, [:user_id, :content_type, :content_id],
              name: 'index_image_uploads_on_user_content_type_id'
    
    # Add composite indexes for common content type queries
    # These are for the most common content types - add more as needed
    
    # Characters
    if table_exists?(:characters)
      add_index :characters, [:user_id, :privacy, :deleted_at],
                name: 'index_characters_on_user_privacy_deleted'
      add_index :characters, [:user_id, :updated_at],
                name: 'index_characters_on_user_updated'
    end
    
    # Locations
    if table_exists?(:locations)
      add_index :locations, [:user_id, :privacy, :deleted_at],
                name: 'index_locations_on_user_privacy_deleted'
      add_index :locations, [:user_id, :updated_at],
                name: 'index_locations_on_user_updated'
    end
    
    # Items
    if table_exists?(:items)
      add_index :items, [:user_id, :privacy, :deleted_at],
                name: 'index_items_on_user_privacy_deleted'
      add_index :items, [:user_id, :updated_at],
                name: 'index_items_on_user_updated'
    end
    
    # Universes
    if table_exists?(:universes)
      add_index :universes, [:user_id, :privacy, :deleted_at],
                name: 'index_universes_on_user_privacy_deleted'
      add_index :universes, [:user_id, :updated_at],
                name: 'index_universes_on_user_updated'
    end
    
    # Documents
    if table_exists?(:documents)
      add_index :documents, [:user_id, :privacy, :deleted_at],
                name: 'index_documents_on_user_privacy_deleted'
    end
    
    # Timelines
    if table_exists?(:timelines)
      add_index :timelines, [:user_id, :privacy, :deleted_at],
                name: 'index_timelines_on_user_privacy_deleted'
    end
    
    # Thredded posts composite indexes for profile queries
    if table_exists?(:thredded_posts)
      add_index :thredded_posts, [:user_id, :created_at, :moderation_state],
                name: 'index_thredded_posts_on_user_created_moderation'
    end
    
    # Page collections
    if table_exists?(:page_collections)
      add_index :page_collections, [:user_id, :updated_at],
                name: 'index_page_collections_on_user_updated'
    end
    
    # Page collection submissions
    if table_exists?(:page_collection_submissions)
      add_index :page_collection_submissions, [:user_id, :status],
                name: 'index_page_collection_submissions_on_user_status'
    end
  end
end