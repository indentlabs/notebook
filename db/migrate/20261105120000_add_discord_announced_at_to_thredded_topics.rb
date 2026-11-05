# NotifyDiscordOfThreadJob is enqueued both when a thread is created and when its first post is
# approved from the moderation queue. It used to avoid posting twice by guessing: "if the first
# post has a moderation record, the approval enqueue will handle it". That guess was wrong when
# only the post was in the queue (e.g. it was reported) -- approving it didn't touch the topic, so
# nothing was announced at all. Recording when a thread was announced lets every enqueue simply
# ask "already announced?".
class AddDiscordAnnouncedAtToThreddedTopics < ActiveRecord::Migration[6.1]
  PENDING_MODERATION = 0

  class MigrationTopic < ActiveRecord::Base
    self.table_name = 'thredded_topics'
  end

  def up
    add_column :thredded_topics, :discord_announced_at, :datetime

    # Treat existing threads as already announced, so approving an old reported post doesn't post
    # an old thread to Discord. The exception is threads still waiting in the moderation queue from
    # the last month: they haven't been announced yet, and should be once a moderator approves them.
    awaiting_review = MigrationTopic.where(moderation_state: PENDING_MODERATION)
                                    .where('created_at > ?', 30.days.ago)
    MigrationTopic.where.not(id: awaiting_review.select(:id))
                  .update_all('discord_announced_at = created_at')
  end

  def down
    remove_column :thredded_topics, :discord_announced_at
  end
end
