class PageCollectionSubmission < ApplicationRecord
  belongs_to :content, polymorphic: true
  belongs_to :page_collection
  belongs_to :user

  after_create :cache_content_name

  scope :accepted, -> { where.not(accepted_at: nil).uniq(&:page_collection_id) }

  def accept!
    update(accepted_at: DateTime.current)

    # TODO Create a "this user got accepted into a submission!" event
    # ContentPageShare.create(
    #   user_id:           self.user_id,
    #   content_page_type: self.class.name,
    #   content_page_id:   self.id,
    #   shared_at:         self.created_at,
    #   privacy:           'public',
    #   message:           self.title,
    # )
  end

  after_create do
    # If the submission was created by the collection owner, we want to automatically approve it.
    # If the collection has opted to automatically accept submissions, we also want to approve it.
    if user == page_collection.user || page_collection.auto_accept?
      update(accepted_at: DateTime.current)

      # TODO Create a "user added a page to their collection" event
    end
  end

  after_create do
    # If the submission needs reviewed, create a notification for the collection owner
    if user != page_collection.user && !page_collection.auto_accept?
      page_collection.user.notifications.create(
        message_html:     "<div><span class='#{User.color}-text'>#{user.display_name}</span> submitted the <span class='#{content.class.color}-text'>#{content.name}</span> #{content_type.downcase} to your <span class='#{PageCollection.color}-text'>#{page_collection.title}</span> collection.</div>",
        icon:             PageCollection.icon,
        icon_color:       PageCollection.color,
        happened_at:      DateTime.current,
        passthrough_link: Rails.application.routes.url_helpers.page_collection_pending_submissions_path(page_collection)
      )
    end
  end

  private

  def cache_content_name
    update(cached_content_name: content.name)
  end
end
