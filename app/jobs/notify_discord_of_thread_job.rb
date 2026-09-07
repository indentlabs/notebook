class NotifyDiscordOfThreadJob < ApplicationJob
  require 'discordrb/webhooks'

  queue_as :low_priority

  # from_moderation is true when this job was enqueued because a moderator
  # approved a thread that was held for moderation (rather than at creation).
  def perform(thread_id, from_moderation = false)
    thread = Thredded::Topic.find_by(id: thread_id)
    return if thread.nil? # deleted before the announcement went out
    return unless thread.moderation_state == "approved"

    # Threads that went through the moderation queue get announced by the
    # approval-time enqueue; skip the creation-time enqueue so approving a
    # thread within the 1-minute announcement delay can't announce it twice.
    return if !from_moderation && went_through_moderation?(thread)

    webhook_url = ENV.fetch('DISCORD_FORUMS_WEBHOOK', '').freeze
    return if webhook_url.blank?

    client = Discordrb::Webhooks::Client.new(url: webhook_url)
    client.execute do |builder|
      builder.content = "New thread in **#{thread.messageboard.name}** by #{thread.user.display_name}"
      builder.add_embed do |embed|
        embed.title = thread.title
        embed.description = thread.first_post.content.truncate(140)
        embed.timestamp = Time.now
        embed.url = "https://www.notebook.ai/forum/#{thread.messageboard.slug}/#{thread.slug}"
        embed.colour = 2201331
      end
    end
  end

  private

  def went_through_moderation?(thread)
    first_post = thread.first_post
    first_post.present? && Thredded::PostModerationRecord.where(post_id: first_post.id).exists?
  end
end
