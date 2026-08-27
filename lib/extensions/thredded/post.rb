# lib/extensions/thredded/post.rb
# frozen_string_literal: true

module Extensions
  module Thredded
    module Post
      extend ActiveSupport::Concern

      # Matches http(s) URLs, protocol-less www. links, and markdown-style links.
      LINK_PATTERN = %r{https?://|\bwww\.|\[[^\]]*\]\([^)\s]+\)}i

      included do
        acts_as_paranoid

        before_create :hold_first_post_with_links_for_moderation
        after_create  :cascade_pending_moderation_to_topic
        after_commit  :notify_moderators_of_new_pending_post,  on: :create
        after_commit  :notify_moderators_of_newly_pended_post, on: :update
      end

      def contains_link?
        content.to_s.match?(LINK_PATTERN)
      end

      private

      # Anti-spam: a user's first-ever forum post containing a link goes to the
      # moderation queue instead of being auto-approved. Pending the user's
      # thredded_user_detail (rather than just this post) means any further posts
      # they make before review are also held, and approving any of their posts
      # from the moderation queue approves the user again (see Thredded::ModeratePost).
      def hold_first_post_with_links_for_moderation
        return unless first_post_with_links_by_new_user?

        # In the new-topic flow the topic's save has already inserted the user's
        # detail row, while this post's user_detail association still points at a
        # separate unsaved instance -- always pend the persisted row and repoint
        # the association at it.
        detail = ::Thredded::UserDetail.find_or_create_by!(user_id: user_id)
        detail.update!(moderation_state: :pending_moderation)
        self.user_detail = detail
        self.moderation_state = :pending_moderation
      end

      def first_post_with_links_by_new_user?
        return false if user.nil?
        return false unless approved? # already pending/blocked users are handled by Thredded
        return false if user.forum_moderator? || user.forum_administrator? || user.site_administrator?
        return false unless contains_link?

        !::Thredded::Post.where(user_id: user_id).exists?
      end

      # Topics are saved before their first post (see Thredded::TopicForm#save),
      # so when that first post is held for moderation the topic has already been
      # created as approved; bring it in line so it is held too.
      def cascade_pending_moderation_to_topic
        return unless pending_moderation?

        topic = postable
        return unless topic.is_a?(::Thredded::Topic)
        return unless topic.approved?
        return unless topic.first_post.nil? || topic.first_post.id == id

        topic.update_columns(moderation_state: ::Thredded::Topic.moderation_states[:pending_moderation])
      end

      # Ping the moderator Discord channel whenever a post lands in the moderation
      # queue (held first post, reported post, or a post by a still-pending user).
      # Only one ping per user while they already have posts waiting in the queue.
      # Note: saved_change_to_moderation_state? can't be checked on create -- in
      # the TopicForm flow the post is inserted by the topic's autosave and then
      # saved again, which clears the change tracking before commit callbacks run.
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
