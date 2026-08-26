# Stream Events Integration

This document explains how to easily create stream events from anywhere in the application using the `StreamEventService`.

## Usage Examples

### 1. Manual Page Sharing

```ruby
# When a user manually shares a page
StreamEventService.create_share_event(
  user: current_user,
  content_page: @character,
  message: "Check out my new character!"
)
```

### 2. Collection Publishing

```ruby
# When a page gets published to a collection
StreamEventService.create_collection_published_event(
  user: @page.user,
  content_page: @page,
  collection: @collection
)
```

### 3. Document Publishing

```ruby
# When a user publishes a document
StreamEventService.create_document_published_event(
  user: current_user,
  document: @document
)
```

### 4. Generic Activity Events

```ruby
# Generic method for various activity types
StreamEventService.create_activity_event(
  user: current_user,
  activity_type: :published_to_collection,
  target: {
    content_page: @page,
    collection: @collection
  }
)
```

## Integration Points

### In Controllers

Add stream events to existing controllers:

```ruby
# In page_collections_controller.rb
def add_page_to_collection
  # ... existing logic ...
  
  if @submission.approved?
    StreamEventService.create_collection_published_event(
      user: @submission.content_page.user,
      content_page: @submission.content_page,
      collection: @collection
    )
  end
end
```

### In Jobs/Background Tasks

```ruby
class PublishToCollectionJob < ApplicationJob
  def perform(page_id, collection_id)
    # ... existing logic ...
    
    StreamEventService.create_activity_event(
      user: page.user,
      activity_type: :published_to_collection,
      target: { content_page: page, collection: collection }
    )
  end
end
```

### In Models (after_save callbacks)

```ruby
class Document < ApplicationRecord
  after_update :create_stream_event_if_published
  
  private
  
  def create_stream_event_if_published
    if saved_change_to_privacy? && privacy == 'public'
      StreamEventService.create_document_published_event(
        user: self.user,
        document: self
      )
    end
  end
end
```

## Extending the System

To add new event types:

1. Add a new method to `StreamEventService`
2. Add a case to `create_activity_event` method
3. Optionally create new partial templates in `app/views/stream/` for custom event rendering

The system is designed to be lightweight and extensible while maintaining consistency with the existing notification system.