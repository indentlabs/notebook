class PageCollectionSubmission < ApplicationRecord
  acts_as_paranoid
  
  belongs_to :content, polymorphic: true
  belongs_to :page_collection
  belongs_to :user

  after_create :mark_related_content_public
  after_create :handle_auto_accept
  after_create :create_submission_notification

  after_create :cache_content_name

  scope :accepted, -> { where.not(accepted_at: nil).uniq(&:page_collection_id) }

  def accept!
    update(accepted_at: DateTime.current)

    # Create a stream event for the user that got accepted
    share = ContentPageShare.create(
      user_id:                     self.user_id,
      content_page_type:           PageCollection.name,
      content_page_id:             page_collection_id,
      secondary_content_page_type: content.class.name,
      secondary_content_page_id:   content.id,
      shared_at:                   self.created_at,
      privacy:                     'public',
      message:                     self.explanation
    )

    # Send a notification to all the users following this collection
    page_collection.followers.each do |user|
      user.notifications.create(
        message_html:     "<div><span class='#{content.class.text_color}'>#{content.name}</span> by <span class='#{User.text_color}'>#{content.user.display_name}</span> was added to the <span class='#{PageCollection.text_color}'>#{page_collection.title}</span> Collection.</div>",
        icon:             PageCollection.icon,
        icon_color:       PageCollection.color,
        happened_at:      DateTime.current,
        passthrough_link: Rails.application.routes.url_helpers.page_collection_path(page_collection)
      )
    end

    # Auto-follow the page collection owner to the share also
    page_collection.user.content_page_share_followings.create({content_page_share: share})
  end

  def mark_related_content_public
    if page_collection.try(:privacy) == 'public'
      content.update(privacy: 'public')
    end
  end

  def handle_auto_accept
    # If the submission was created by the collection owner, we want to automatically approve it.
    # If the collection has opted to automatically accept submissions, we also want to approve it.
    if user == page_collection.user || page_collection.auto_accept?
      update(accepted_at: DateTime.current)

      # Create a "user added a page to their collection" event if the page and the collection are public
      if page_collection.try(:privacy) == 'public'
        share = ContentPageShare.create(
          user_id:                     self.user_id,
          content_page_type:           PageCollection.name,
          content_page_id:             page_collection_id,
          secondary_content_page_type: content.class.name,
          secondary_content_page_id:   content.id,
          shared_at:                   self.created_at,
          privacy:                     'public',
          message:                     self.explanation
        )
      end
    end
  end

  def create_submission_notification
    # If the submission needs reviewed, create a notification for the collection owner
    if user != page_collection.user && !page_collection.auto_accept?
      page_collection.user.notifications.create(
        message_html:     "<div><span class='#{User.text_color}'>#{user.display_name}</span> submitted the <span class='#{content.class.text_color}'>#{content.name}</span> #{content_type.downcase} to your <span class='#{PageCollection.text_color}'>#{page_collection.title}</span> collection.</div>",
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
