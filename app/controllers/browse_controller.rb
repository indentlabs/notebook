class BrowseController < ApplicationController
  # This controller handles browsing global content across the site

  def tag
    @tag_slug = params[:tag_slug]
    
    # For now, only allow ArtFight2025 tag to be browsed (case insensitive)
    unless @tag_slug.downcase == 'artfight2025'
      redirect_to root_path, notice: 'This tag is not available for browsing.'
      return
    end
    
    @tag = 'ArtFight2025'
    @tag_slug = 'artfight2025' # Use the correctly slugified version
    @tagged_content = []
    
    # Directly check database for any pages with this tag
    tag_exists = PageTag.exists?(slug: @tag_slug)
    
    if tag_exists
      # Calculate a daily seed for consistent randomization across page refreshes in same day
      # This allows for caching while still changing the order daily
      daily_seed = Date.today.to_time.to_i
      
      # Number of items to show per content type to avoid performance issues
      per_type_limit = 50
      
      # Go through each content type and find public items with this tag
      Rails.application.config.content_types[:all].each do |content_type|
        # First find page IDs with this tag
        tag_page_ids = PageTag.where(page_type: content_type.name, slug: @tag_slug).pluck(:page_id)
        
        if tag_page_ids.any?
          # Use database-level randomization with the daily seed for caching potential
          # Use PostgreSQL's random function with a seed derived from the ID and daily seed
          # This is much more efficient than loading all records into memory
          content_pages = content_type.where(id: tag_page_ids)
                                    .where(privacy: 'public')
                                    .order(Arel.sql("RANDOM()"))
                                    .limit(per_type_limit)

          @tagged_content << {
            type: content_type.name,
            icon: content_type.icon,
            color: content_type.color,
            content: content_pages
          } if content_pages.any?
        end
      end
      
      # Add documents separately since they don't use the common content type structure
      document_tag_page_ids = PageTag.where(page_type: 'Document', slug: @tag_slug).pluck(:page_id)
      if document_tag_page_ids.any?
        documents = Document.where(id: document_tag_page_ids)
                          .where(privacy: 'public')
                          .order(Arel.sql("RANDOM()"))
                          .limit(per_type_limit)
        
        @tagged_content << {
          type: 'Document',
          icon: 'description',
          color: 'blue',
          content: documents
        } if documents.any?
      end
      
      # Add timelines separately since they don't use the common content type structure
      timeline_tag_page_ids = PageTag.where(page_type: 'Timeline', slug: @tag_slug).pluck(:page_id)
      if timeline_tag_page_ids.any?
        timelines = Timeline.where(id: timeline_tag_page_ids)
                          .where(privacy: 'public')
                          .order(Arel.sql("RANDOM()"))
                          .limit(per_type_limit)
        
        @tagged_content << {
          type: 'Timeline',
          icon: 'timeline',
          color: 'blue',
          content: timelines
        } if timelines.any?
      end
      
      # Get images for content cards from all users
      content_ids_by_type = {}
      user_ids = []
      
      @tagged_content.each do |content_group|
        content_group[:content].each do |content|
          content_type = content.class.name
          content_ids_by_type[content_type] ||= []
          content_ids_by_type[content_type] << content.id
          user_ids << content.user_id
        end
      end
      
      # Get unique user IDs
      user_ids.uniq!
      
      # Get all relevant images - optimize with a single query per content type
      @random_image_pool_cache = {}
      if content_ids_by_type.any?
        content_ids_by_type.each do |content_type, ids|
          images = ImageUpload.where(content_type: content_type, content_id: ids)
          
          images.each do |image|
            key = [image.content_type, image.content_id]
            @random_image_pool_cache[key] ||= []
            @random_image_pool_cache[key] << image
          end
        end
      end
      
      # Initialize basil commissions if there are any content items
      if content_ids_by_type.any?
        entity_types = []
        entity_ids = []
        
        content_ids_by_type.each do |content_type, ids|
          entity_type = content_type.downcase.pluralize
          entity_types.concat([entity_type] * ids.length)
          entity_ids.concat(ids)
        end
        
        @saved_basil_commissions = BasilCommission.where(
          entity_type: entity_types,
          entity_id: entity_ids
        ).where.not(saved_at: nil)
        .group_by { |commission| [commission.entity_type, commission.entity_id] }
      end
      
      # Get usernames for display with content - optimize with a single query
      @users_cache = User.where(id: user_ids).index_by(&:id)
    end
    
    # Set a default accent color for the page
    @accent_color = 'purple'
    
    # Sort content types so Characters always appear first
    @tagged_content = @tagged_content.sort_by do |content_group|
      if content_group[:type] == 'Character'
        # Characters first
        "0_#{content_group[:type]}"
      else
        # Everything else alphabetically
        "1_#{content_group[:type]}"
      end
    end
    
    @sidenav_expansion = 'community'
  end
end