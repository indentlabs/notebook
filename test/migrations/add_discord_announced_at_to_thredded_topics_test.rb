require "test_helper"
require Rails.root.join("db/migrate/20261105120000_add_discord_announced_at_to_thredded_topics")

class AddDiscordAnnouncedAtToThreddedTopicsTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    @messageboard = Thredded::Messageboard.create!(name: "Backfill board")
  end

  teardown do
    Thredded::Topic.with_deleted.where(messageboard_id: @messageboard.id).find_each(&:really_destroy!)
    Thredded::Post.with_deleted.where(messageboard_id: @messageboard.id).find_each(&:really_destroy!)
    @messageboard.destroy
    Thredded::UserDetail.where(user_id: users(:one).id).delete_all
  end

  def topic(state, created_at)
    form = Thredded::TopicForm.new(title: "#{state} #{created_at.to_i}", content: "Hi",
                                   user: users(:one), messageboard: @messageboard)
    assert form.save
    form.topic.tap do |t|
      t.update_columns(moderation_state: Thredded::Topic.moderation_states[state], created_at: created_at)
    end
  end

  test "marks existing threads as announced, except recent ones still awaiting review" do
    old_approved = topic(:approved, 2.years.ago)
    old_pending  = topic(:pending_moderation, 2.years.ago)
    new_pending  = topic(:pending_moderation, 2.days.ago)

    migration = AddDiscordAnnouncedAtToThreddedTopics.new.tap { |m| m.verbose = false }
    migration.migrate(:down)
    Thredded::Topic.reset_column_information
    migration.migrate(:up)
    Thredded::Topic.reset_column_information

    assert_in_delta old_approved.created_at, old_approved.reload.discord_announced_at, 1
    assert old_pending.reload.discord_announced_at.present?
    assert_nil new_pending.reload.discord_announced_at
  end
end
