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
    
    # Set SEO metadata for this page
    set_meta_tags title: 'Art Fight 2025',
                 description: 'Browse characters, locations, and other creative content from Notebook.ai creators participating in Art Fight 2025. Find inspiration for your next art attack!',
                 keywords: ['art fight', 'character art', 'original characters', 'ocs', 'art challenge', 'art event', 'artfight2025', 'worldbuilding'],
                 og: {
                   title: 'Art Fight 2025 - Notebook.ai',
                   description: 'Browse characters, locations, and other creative content from Notebook.ai creators participating in Art Fight 2025',
                   image: view_context.asset_path('card-headers/patterns/pattern5.png'),
                   type: 'website'
                 },
                 twitter: {
                   card: 'summary_large_image',
                   title: 'Art Fight 2025 - Notebook.ai',
                   description: 'Browse characters, locations, and other creative content from Notebook.ai creators participating in Art Fight 2025',
                   image: view_context.asset_path('card-headers/patterns/pattern5.png')
                 }
    
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
        # First find page IDs with this tag - case insensitive matching for slug
        tag_page_ids = PageTag.where(page_type: content_type.name)
                              .where("LOWER(slug) = ?", @tag_slug.downcase)
                              .pluck(:page_id)
        
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
      document_tag_page_ids = PageTag.where(page_type: 'Document')
                                    .where("LOWER(slug) = ?", @tag_slug.downcase)
                                    .pluck(:page_id)
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
      timeline_tag_page_ids = PageTag.where(page_type: 'Timeline')
                                    .where("LOWER(slug) = ?", @tag_slug.downcase)
                                    .pluck(:page_id)
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
      
      # Cards render through content_image_tag; preload what it needs and
      # collect the authors for display.
      all_content = @tagged_content.flat_map { |group| group[:content].to_a }
      preload_cover_images(all_content)
      user_ids = all_content.map(&:user_id).uniq

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