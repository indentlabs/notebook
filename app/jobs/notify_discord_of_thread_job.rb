class NotifyDiscordOfThreadJob < ApplicationJob
  require 'discordrb/webhooks'

  queue_as :low_priority

  def perform(*args)
    thread_id = args.shift
    thread    = Thredded::Topic.find_by(id: thread_id)
    raise "No thread found for new ID #{thread.id.inspect}" unless thread
    return if thread.moderation_state == "blocked"

    webhook_url = ENV.fetch('DISCORD_FORUMS_WEBHOOK', '').freeze

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
end
