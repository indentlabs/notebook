class StreamEventService
  def self.create_share_event(user:, content_page:, message: nil)
    return unless user && content_page
    
    # Make the content page public when sharing
    content_page.update(privacy: 'public') if content_page.respond_to?(:privacy)
    
    ContentPageShare.create!(
      user: user,
      content_page: content_page,
      message: message,
      shared_at: DateTime.current
    )
  end
  
  def self.create_collection_published_event(user:, content_page:, collection:)
    return unless user && content_page && collection
    
    message = "#{content_page.name} was featured in the collection #{collection.name}!"
    
    create_share_event(
      user: user,
      content_page: content_page,
      message: message
    )
  end
  
  def self.create_forum_thread_event(user:, thread_title:, thread_url:)
    # For forum threads, we'll need to create a different type of stream event
    # This would require extending the ContentPageShare model or creating a new model
    # For now, this is a placeholder for future implementation
    Rails.logger.info "StreamEventService: Would create forum thread event for #{user.display_name}: #{thread_title}"
  end
  
  def self.create_document_published_event(user:, document:)
    return unless user && document
    
    create_share_event(
      user: user,
      content_page: document,
      message: "Just published this document!"
    )
  end
  
  # Helper method to create notification-style stream events
  def self.create_activity_event(user:, activity_type:, target:, message: nil)
    case activity_type
    when :published_to_collection
      create_collection_published_event(
        user: user,
        content_page: target[:content_page],
        collection: target[:collection]
      )
    when :shared_document
      create_document_published_event(user: user, document: target)
    when :forum_thread
      create_forum_thread_event(
        user: user,
        thread_title: target[:title],
        thread_url: target[:url]
      )
    else
      Rails.logger.warn "StreamEventService: Unknown activity type: #{activity_type}"
    end
  end
end