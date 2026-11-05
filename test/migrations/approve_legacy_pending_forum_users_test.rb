require "test_helper"
require "webmock/minitest"
require Rails.root.join("db/migrate/20261105120000_approve_legacy_pending_forum_users")

class ApproveLegacyPendingForumUsersTest < ActiveSupport::TestCase
  WEBHOOK_URL = "https://discord.test/api/webhooks/456/def".freeze

  setup do
    ENV["DISCORD_FORUMS_WEBHOOK"] = WEBHOOK_URL
    WebMock.stub_request(:post, WEBHOOK_URL).to_return(status: 204)
  end

  teardown do
    ENV.delete("DISCORD_FORUMS_WEBHOOK")
  end

  def migrate
    ApproveLegacyPendingForumUsers.new.tap { |m| m.verbose = false }.migrate(:up)
  end

  # A row created while the column defaulted to pending_moderation, and never changed since.
  def legacy_pending_detail(user)
    detail = Thredded::UserDetail.find_or_create_by!(user_id: user.id)
    detail.update_columns(moderation_state: Thredded::UserDetail.moderation_states[:pending_moderation],
                          moderation_state_changed_at: nil)
    detail
  end

  test "approves accounts left pending by the old column default" do
    detail = legacy_pending_detail(users(:one))

    migrate

    assert detail.reload.approved?
  end

  test "leaves accounts that were pended on purpose alone" do
    detail = Thredded::UserDetail.find_or_create_by!(user_id: users(:one).id)
    detail.update!(moderation_state: :pending_moderation) # as automoderation or a moderator does
    assert detail.reload.moderation_state_changed_at.present?

    migrate

    assert detail.reload.pending_moderation?
  end

  test "approves pending staff accounts even if they were pended on purpose" do
    users(:two).update!(site_administrator: true)
    detail = Thredded::UserDetail.find_or_create_by!(user_id: users(:two).id)
    detail.update!(moderation_state: :pending_moderation)

    migrate

    assert detail.reload.approved?
  end

  test "leaves blocked accounts blocked" do
    detail = Thredded::UserDetail.find_or_create_by!(user_id: users(:one).id)
    detail.update_columns(moderation_state: Thredded::UserDetail.moderation_states[:blocked],
                          moderation_state_changed_at: nil)

    migrate

    assert detail.reload.blocked?
  end

  test "new threads by a previously stuck account are announced on Discord again" do
    admin = users(:one)
    admin.update!(site_administrator: true)
    legacy_pending_detail(admin)
    messageboard = Thredded::Messageboard.create!(name: "Announcements")

    post_thread = lambda do |title|
      form = Thredded::TopicForm.new(title: title, content: "See https://www.notebook.ai/changelog",
                                     user: admin, messageboard: messageboard)
      assert form.save, form.errors.full_messages.to_sentence
      form.topic.reload
    end

    stuck = post_thread.call("Before the fix")
    assert stuck.pending_moderation?, "threads inherit the account's legacy pending state"
    NotifyDiscordOfThreadJob.perform_now(stuck.id)
    WebMock.assert_not_requested(:post, WEBHOOK_URL)

    migrate

    announced = post_thread.call("After the fix")
    assert announced.approved?
    NotifyDiscordOfThreadJob.perform_now(announced.id)
    WebMock.assert_requested(:post, WEBHOOK_URL, times: 1)
  end
end
