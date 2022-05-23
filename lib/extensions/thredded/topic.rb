# lib/extensions/thredded/topic.rb
# frozen_string_literal: true

module Extensions
  module Thredded
    module Topic
      extend ActiveSupport::Concern
      
      included do
        after_create :create_content_page_share
        after_create :notify_discord
        has_many     :content_page_shares, as: :content

        acts_as_paranoid

        def self.icon
          'forum'
        end

        def self.color
          'blue'
        end

        def self.text_color
          'blue-text'
        end
      end

      def notify_discord
        NotifyDiscordOfThreadJob.set(wait: 1.minute).perform_later(self.id)
      end

      def create_content_page_share
        ContentPageShare.create(
          user_id:           self.user_id,
          content_page_type: self.class.name,
          content_page_id:   self.id,
          shared_at:         self.created_at,
          privacy:           'public',
          message:           self.title,
        )
      end

      def random_public_image
        "card-headers/discussions.webp"
      end

      def first_public_image
        "card-headers/discussions.webp"
      end

      def name
        self.title
      end
    end
  end
end