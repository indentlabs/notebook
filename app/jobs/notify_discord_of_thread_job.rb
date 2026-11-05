class NotifyDiscordOfThreadJob < ApplicationJob
  require 'discordrb/webhooks'

  queue_as :low_priority

  # from_moderation is true when this job was enqueued because a moderator
  # approved a thread that was held for moderation (rather than at creation).
  def perform(thread_id, from_moderation = false)
    thread = Thredded::Topic.find_by(id: thread_id)
    return log_skip(thread_id, 'it no longer exists') if thread.nil? # deleted before the announcement went out
    # Don't announce blocked threads, or threads held in the moderation queue (e.g. by automoderation)
    return log_skip(thread_id, "it is #{thread.moderation_state}") unless thread.approved?

    # Threads that went through the moderation queue get announced by the
    # approval-time enqueue; skip the creation-time enqueue so approving a
    # thread within the 1-minute announcement delay can't announce it twice.
    if !from_moderation && went_through_moderation?(thread)
      return log_skip(thread_id, 'it went through moderation and is announced on approval')
    end

    webhook_url = ENV.fetch('DISCORD_FORUMS_WEBHOOK', '').freeze
    return log_skip(thread_id, 'DISCORD_FORUMS_WEBHOOK is not set') if webhook_url.blank?

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

  # Skipping is expected (held or blocked threads), so it isn't an error, but log it so a missing
  # announcement can be traced from the worker logs.
  def log_skip(thread_id, reason)
    Rails.logger.info("[NotifyDiscordOfThreadJob] Not announcing thread #{thread_id}: #{reason}")
    nil
  end

  def went_through_moderation?(thread)
    first_post = thread.first_post
    first_post.present? && Thredded::PostModerationRecord.where(post_id: first_post.id).exists?
  end
end
