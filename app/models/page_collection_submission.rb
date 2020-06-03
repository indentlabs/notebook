class PageCollectionSubmission < ApplicationRecord
  belongs_to :content, polymorphic: true
  belongs_to :page_collection
  belongs_to :user

  after_create do
    # If the submission was created by the collection owner, we want to automatically approve it.
    # If the collection has opted to automatically accept submissions, we also want to approve it.
    if user == page_collection.user || page_collection.auto_accept?
      update(accepted_at: DateTime.current)
    end
  end

  after_create do
    # Cache the name of the content to make sorting submissions by content name easier/faster
    update(cached_content_name: content.name)
  end
end
