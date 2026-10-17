# lib/extensions/thredded/post.rb
# frozen_string_literal: true

module Extensions
  module Thredded
    module Post
      extend ActiveSupport::Concern

      # Accounts younger than this are considered "new" for automoderation purposes.
      NEW_ACCOUNT_AGE = 5.days

      # Anything that looks like a link: explicit URLs, www-prefixed hosts, BBCode/HTML links,
      # or a bare domain on a common TLD (e.g. "cheap-pills.shop").
      LINK_PATTERN = %r{
        https?://
        | \bwww\.
        | \[url
        | <a\s
        | \b[a-z0-9-]+\.(?:com|net|org|info|biz|io|ly|xyz|top|site|online|shop|store|club|ru|cn)\b
      }xi

      included do
        acts_as_paranoid

        before_create :hold_new_user_first_link_post_for_moderation
        after_create  :hold_new_topic_for_moderation, if: :held_by_automoderation?
      end

      def held_by_automoderation?
        !!@held_by_automoderation
      end

      private

      # Automoderation rule: if a new account's very first forum post (or the first post of a new topic)
      # contains a link, put it in the moderation queue instead of publishing it as approved.
      def hold_new_user_first_link_post_for_moderation
        return if user.nil? || pending_moderation? || blocked?
        return unless user.created_at.present? && user.created_at > NEW_ACCOUNT_AGE.ago
        return unless contains_link?
        return if user_has_previous_posts?

        self.moderation_state = :pending_moderation
        @held_by_automoderation = true
      end

      # When the held post is the first post of a brand-new topic, hold the topic too. This also keeps
      # NotifyDiscordOfThreadJob from announcing it.
      def hold_new_topic_for_moderation
        return if postable.nil? || postable.posts.where.not(id: id).exists?

        postable.update_columns(moderation_state: ::Thredded::Topic.moderation_states[:pending_moderation])
      end

      def contains_link?
        text = [content, (postable.title if postable.respond_to?(:title))].compact.join("\n")
        LINK_PATTERN.match?(text)
      end

      def user_has_previous_posts?
        # Include soft-deleted posts so a spammer whose first post was removed doesn't get a fresh pass.
        ::Thredded::Post.with_deleted.where(user_id: user_id).where.not(id: id).exists?
      end
    end
  end
end
