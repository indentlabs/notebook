class NotifyDiscordOfPendingPostJob < ApplicationJob
  require 'discordrb/webhooks'

  queue_as :low_priority

  def perform(post_id)
    post = Thredded::Post.find_by(id: post_id)
    return if post.nil?
    return unless post.moderation_state == "pending_moderation"

    webhook_url = ENV.fetch('DISCORD_MODERATION_WEBHOOK', '').freeze
    return if webhook_url.blank?

    author = post.user ? post.user.display_name : 'an anonymous user'
    client = Discordrb::Webhooks::Client.new(url: webhook_url)
    client.execute do |builder|
      builder.content = "Post by **#{author}** in **#{post.messageboard.name}** is waiting for review"
      builder.add_embed do |embed|
        embed.title = post.postable.title
        embed.description = post.content.truncate(140)
        embed.timestamp = Time.now
        embed.url = "https://www.notebook.ai/forum/moderation"
        embed.colour = 15158332
      end
    end
  end
end
