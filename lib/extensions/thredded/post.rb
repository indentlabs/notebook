# lib/extensions/thredded/post.rb
# frozen_string_literal: true

module Extensions
  module Thredded
    module Post
      extend ActiveSupport::Concern

      # Accounts younger than this are considered "new" for automoderation purposes.
      NEW_ACCOUNT_AGE = 5.days

      # Anything that looks like a link: explicit URLs, www-prefixed hosts, markdown/BBCode/HTML
      # links, or a bare domain on a common TLD (e.g. "cheap-pills.shop").
      LINK_PATTERN = %r{
        https?://
        | \bwww\.
        | \[url
        | <a\s
        | \[[^\]]*\]\([^)\s]+\)
        | \b[a-z0-9-]+\.(?:com|net|org|info|biz|io|ly|xyz|top|site|online|shop|store|club|ru|cn)\b
      }xi

      included do
        acts_as_paranoid

        before_create :hold_new_user_first_link_post_for_moderation
        after_create  :cascade_pending_moderation_to_topic
        after_commit  :notify_moderators_of_new_pending_post,  on: :create
        after_commit  :notify_moderators_of_newly_pended_post, on: :update
      end

      def held_by_automoderation?
        !!@held_by_automoderation
      end

      def contains_link?
        text = [content, (postable.title if postable.respond_to?(:title))].compact.join("\n")
        LINK_PATTERN.match?(text)
      end

      private

      # Automoderation rule: if a new account's very first forum post (or the first post of a new
      # topic) contains a link, put it in the moderation queue instead of publishing it as approved.
      # Pending the user's thredded_user_detail (rather than just this post) means any further
      # posts they make before review are also held, and approving any of their posts from the
      # moderation queue approves the user again (see Thredded::ModeratePost).
      def hold_new_user_first_link_post_for_moderation
        return if user.nil? || pending_moderation? || blocked?
        return if user.forum_moderator? || user.forum_administrator? || user.site_administrator?
        return unless user.created_at.present? && user.created_at > NEW_ACCOUNT_AGE.ago
        return unless contains_link?
        return if user_has_previous_posts?

        # In the new-topic flow the topic's save has already inserted the user's detail row, while
        # this post's user_detail association still points at a separate unsaved instance -- always
        # pend the persisted row and repoint the association at it.
        detail = ::Thredded::UserDetail.find_or_create_by!(user_id: user_id)
        detail.update!(moderation_state: :pending_moderation)
        self.user_detail = detail
        self.moderation_state = :pending_moderation
        @held_by_automoderation = true
      end

      def user_has_previous_posts?
        # Include soft-deleted posts so a spammer whose first post was removed doesn't get a fresh pass.
        ::Thredded::Post.with_deleted.where(user_id: user_id).where.not(id: id).exists?
      end

      # Topics are saved before their first post (see Thredded::TopicForm#save), so when the first
      # post of a new topic is held the topic has already been created as approved; bring it in
      # line so it is held too. This also keeps NotifyDiscordOfThreadJob from announcing it.
      def cascade_pending_moderation_to_topic
        return unless pending_moderation?

        topic = postable
        return unless topic.is_a?(::Thredded::Topic)
        return unless topic.approved?
        return if topic.posts.where.not(id: id).exists?

        topic.update_columns(moderation_state: ::Thredded::Topic.moderation_states[:pending_moderation])
      end

      # Ping the moderator Discord channel whenever a post lands in the moderation queue (held
      # first post, reported post, or a post by a still-pending user). Only one ping per user
      # while they already have posts waiting in the queue.
      # Note: saved_change_to_moderation_state? can't be checked on create -- in the TopicForm
      # flow the post is inserted by the topic's autosave and then saved again, which clears the
      # change tracking before commit callbacks run.
      def notify_moderators_of_new_pending_post
        return unless pending_moderation?

        notify_moderators_of_pending_post
      end

      def notify_moderators_of_newly_pended_post
        return unless pending_moderation? && saved_change_to_moderation_state?

        notify_moderators_of_pending_post
      end

      def notify_moderators_of_pending_post
        return if ::Thredded::Post.pending_moderation.where(user_id: user_id).where.not(id: id).exists?

        NotifyDiscordOfPendingPostJob.perform_later(id)
      end
    end
  end
end
