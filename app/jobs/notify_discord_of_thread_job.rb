class NotifyDiscordOfThreadJob < ApplicationJob
  require 'discordrb/webhooks'

  queue_as :low_priority

  # Enqueued when a thread is created (Extensions::Thredded::Topic#notify_discord) and again when
  # its first post is approved from the moderation queue
  # (Extensions::Thredded::Post#announce_thread_on_first_post_approval). Whichever run finds the
  # thread approved first announces it; the topic's discord_announced_at makes it happen only once.
  #
  # The second argument is unused; it's accepted so jobs enqueued by older code still run.
  def perform(thread_id, _from_moderation = nil)
    thread = Thredded::Topic.find_by(id: thread_id)
    return log_skip(thread_id, 'it no longer exists') if thread.nil?
    # Don't announce blocked threads, or threads held in the moderation queue (e.g. by automoderation)
    return log_skip(thread_id, "it is #{thread.moderation_state}") unless thread.approved?

    first_post = thread.first_post
    return log_skip(thread_id, 'it has no first post') if first_post.nil?
    # A reported (or otherwise held) first post is announced once a moderator approves it.
    return log_skip(thread_id, "its first post is #{first_post.moderation_state}") unless first_post.approved?

    return log_skip(thread_id, 'it was already announced') if thread.discord_announced_at.present?

    webhook_url = ENV.fetch('DISCORD_FORUMS_WEBHOOK', '').freeze
    return log_skip(thread_id, 'DISCORD_FORUMS_WEBHOOK is not set') if webhook_url.blank?

    # Claim the announcement atomically so two runs at the same moment can't both post it.
    claimed = Thredded::Topic.where(id: thread.id, discord_announced_at: nil)
                             .update_all(discord_announced_at: Time.current) == 1
    return log_skip(thread_id, 'it was already announced') unless claimed

    begin
      announce(thread, first_post, webhook_url)
    rescue StandardError
      # Let the retry announce it.
      Thredded::Topic.where(id: thread.id).update_all(discord_announced_at: nil)
      raise
    end
  end

  private

  def announce(thread, first_post, webhook_url)
    client = Discordrb::Webhooks::Client.new(url: webhook_url)
    client.execute do |builder|
      builder.content = "New thread in **#{thread.messageboard.name}** by #{thread.user.display_name}"
      builder.add_embed do |embed|
        embed.title = thread.title
        embed.description = first_post.content.truncate(140)
        embed.timestamp = Time.now
        embed.url = "https://www.notebook.ai/forum/#{thread.messageboard.slug}/#{thread.slug}"
        embed.colour = 2201331
      end
    end
  end

  # Skipping is expected (held or blocked threads), so it isn't an error, but log it so a missing
  # announcement can be traced from the worker logs.
  def log_skip(thread_id, reason)
    Rails.logger.info("[NotifyDiscordOfThreadJob] Not announcing thread #{thread_id}: #{reason}")
    nil
  end
end
