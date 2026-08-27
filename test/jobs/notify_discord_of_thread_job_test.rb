require 'test_helper'
require 'webmock'

class NotifyDiscordOfThreadJobTest < ActiveSupport::TestCase
  WEBHOOK_URL = 'https://discord.test/api/webhooks/123/abc'.freeze

  def setup
    @user         = users(:one)
    @moderator    = users(:two)
    @moderator.update!(forum_moderator: true)
    @messageboard = Thredded::Messageboard.create!(name: "Job test board")

    ENV['DISCORD_FORUMS_WEBHOOK'] = WEBHOOK_URL
    WebMock.enable!
    WebMock.stub_request(:post, WEBHOOK_URL).to_return(status: 204)
  end

  def teardown
    WebMock.reset!
    WebMock.disable!
    ENV.delete('DISCORD_FORUMS_WEBHOOK')
  end

  def create_topic(content)
    form = Thredded::TopicForm.new(
      title:        "A topic",
      content:      content,
      user:         @user,
      messageboard: @messageboard
    )
    assert form.save, "expected topic form to save"
    form.topic
  end

  test "announces approved threads" do
    topic = create_topic("Hello, no links here")

    NotifyDiscordOfThreadJob.perform_now(topic.id)

    WebMock.assert_requested(:post, WEBHOOK_URL)
  end

  test "does not announce threads held for moderation" do
    topic = create_topic("Spam: https://spam.example.com")
    assert topic.reload.pending_moderation?

    NotifyDiscordOfThreadJob.perform_now(topic.id)

    WebMock.assert_not_requested(:post, WEBHOOK_URL)
  end

  test "announces a held thread once when it is approved" do
    topic = create_topic("Link: https://example.com")
    Thredded::ModeratePost.run!(
      post:             topic.reload.first_post,
      moderation_state: :approved,
      moderator:        @moderator
    )

    # The approval-time enqueue announces it...
    NotifyDiscordOfThreadJob.perform_now(topic.id, true)
    # ...and the creation-time enqueue (fires 1 minute after creation) skips it.
    NotifyDiscordOfThreadJob.perform_now(topic.id)

    WebMock.assert_requested(:post, WEBHOOK_URL, times: 1)
  end
end
