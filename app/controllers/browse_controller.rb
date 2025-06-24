class BrowseController < ApplicationController
  # This controller handles browsing global content across the site

  def tag
    @tag_slug = params[:tag_slug]
    # Debug logging
    Rails.logger.info "BrowseController#tag - Looking for content with tag slug: #{@tag_slug}"
    
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
    Rails.logger.info "Tag exists in PageTag table? #{tag_exists}"
    
    if tag_exists
      sample_tag = PageTag.find_by(slug: @tag_slug)
      Rails.logger.info "Sample tag: #{sample_tag.inspect}" 
    end
    
    # Go through each content type and find public items with this tag
    Rails.application.config.content_types[:all].each do |content_type|
      # Try a different query approach - first find page IDs with this tag
      tag_page_ids = PageTag.where(page_type: content_type.name, slug: @tag_slug).pluck(:page_id)
      
      if tag_page_ids.any?
        Rails.logger.info "Found #{tag_page_ids.count} #{content_type.name} page IDs with tag: #{tag_page_ids}"
        content_pages = content_type.where(id: tag_page_ids).where(privacy: 'public').order(:name)
      else
        Rails.logger.info "No #{content_type.name} pages found with tag"
        content_pages = content_type.none
      end

      @tagged_content << {
        type: content_type.name,
        icon: content_type.icon,
        color: content_type.color,
        content: content_pages
      } if content_pages.any?
    end
    
    # Add documents separately since they don't use the common content type structure
    document_tag_page_ids = PageTag.where(page_type: 'Document', slug: @tag_slug).pluck(:page_id)
    if document_tag_page_ids.any?
      Rails.logger.info "Found #{document_tag_page_ids.count} Document page IDs with tag: #{document_tag_page_ids}"
      documents = Document.where(id: document_tag_page_ids).where(privacy: 'public').order(:title)
    else
      Rails.logger.info "No Document pages found with tag"
      documents = Document.none
    end # Documents use 'title' instead of 'name'
                      
    @tagged_content << {
      type: 'Document',
      icon: 'description',
      color: 'blue',
      content: documents
    } if documents.any?
    
    # Add timelines separately since they don't use the common content type structure
    timeline_tag_page_ids = PageTag.where(page_type: 'Timeline', slug: @tag_slug).pluck(:page_id)
    if timeline_tag_page_ids.any?
      Rails.logger.info "Found #{timeline_tag_page_ids.count} Timeline page IDs with tag: #{timeline_tag_page_ids}"
      timelines = Timeline.where(id: timeline_tag_page_ids).where(privacy: 'public').order(:name)
    else
      Rails.logger.info "No Timeline pages found with tag"
      timelines = Timeline.none
    end
                      
    @tagged_content << {
      type: 'Timeline',
      icon: 'timeline',
      color: 'blue',
      content: timelines
    } if timelines.any?
    
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
    
    # Get all relevant images
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
    
    # Set a default accent color for the page
    @accent_color = 'purple'
    
    # Get usernames for display with content
    @users_cache = User.where(id: user_ids).index_by(&:id)
    
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