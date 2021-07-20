# This job is kicked off each time a ContentPageShare is commented on, creating notifications
# for all users that are following that share.
class ContentPageShareNotificationJob < ApplicationJob
  queue_as :notifications

  def perform(*args)
    share_comment_id = args.shift
    comment = ShareComment.find_by(id: share_comment_id)
    return unless comment.present?

    comment.content_page_share.content_page_share_followings.each do |following|
      # Don't notify the user who made the comment -- they already know.
      next if comment.user == following.user

      following.user.notifications.create(
        message_html:     "<div><span class='#{User.text_color}'>#{comment.user.display_name}</span> commented on #{comment.user == comment.content_page_share.content_page.user ? 'the' : 'your'} shared #{comment.content_page_share.content_page.class.name.downcase} <span class='#{comment.content_page_share.content_page.class.text_color}'>#{comment.content_page_share.content_page.name}</span>.</div>",
        icon:             comment.content_page_share.content_page.class.icon,
        icon_color:       comment.content_page_share.content_page.class.color,
        happened_at:      DateTime.current,
        passthrough_link: Rails.application.routes.url_helpers.user_content_page_share_path(
          id:      comment.content_page_share.id,
          user_id: comment.content_page_share.user_id
        )
      )
    end
  end
end
