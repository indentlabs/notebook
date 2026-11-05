require 'test_helper'
require 'minitest/mock'
# webmock/minitest enables WebMock for the whole test process and resets stubs
# between tests; never WebMock.disable! here, as that would turn interception
# off for every test that runs afterwards (e.g. GenerateBasilImageJobTest).
require 'webmock/minitest'

class NotifyDiscordOfThreadJobTest < ActiveJob::TestCase
  WEBHOOK_URL = 'https://discord.test/api/webhooks/123/abc'.freeze

  # setup/teardown blocks (not method overrides) keep webmock/minitest's
  # teardown chain intact so stubs and request history reset between tests.
  setup do
    @user         = users(:one)
    @moderator    = users(:two)
    @moderator.update!(forum_moderator: true)
    @messageboard = Thredded::Messageboard.create!(name: "Job test board")

    ENV['DISCORD_FORUMS_WEBHOOK'] = WEBHOOK_URL
    WebMock.stub_request(:post, WEBHOOK_URL).to_return(status: 204)
  end

  teardown do
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
    form.topic.reload
  end

  def approve(post)
    Thredded::ModeratePost.run!(post: post, moderation_state: :approved, moderator: @moderator)
  end

  # What Thredded::PostsController#report does.
  def report(post)
    post.update!(moderation_state: 'pending_moderation')
  end

  # Enqueueing is skipped outside production, so pretend to be production to see the jobs.
  def in_production(&block)
    Rails.stub(:env, ActiveSupport::StringInquirer.new('production'), &block)
  end

  test "announces approved threads once" do
    topic = create_topic("Hello, no links here")

    NotifyDiscordOfThreadJob.perform_now(topic.id)
    NotifyDiscordOfThreadJob.perform_now(topic.id)

    WebMock.assert_requested(:post, WEBHOOK_URL, times: 1)
    assert topic.reload.discord_announced_at.present?
  end

  test "does not announce threads held for moderation" do
    topic = create_topic("Spam: https://spam.example.com")
    assert topic.pending_moderation?

    NotifyDiscordOfThreadJob.perform_now(topic.id)

    WebMock.assert_not_requested(:post, WEBHOOK_URL)
    assert_nil topic.reload.discord_announced_at
  end

  test "announces a held thread once when it is approved" do
    topic = create_topic("Link: https://example.com")
    approve(topic.first_post)

    # The approval-time enqueue announces it...
    NotifyDiscordOfThreadJob.perform_now(topic.id)
    # ...and the creation-time enqueue (fires 1 minute after creation) skips it.
    NotifyDiscordOfThreadJob.perform_now(topic.id)

    WebMock.assert_requested(:post, WEBHOOK_URL, times: 1)
  end

  # The thread was approved all along; only its first post went through the queue, so approving
  # the post doesn't change the topic. This used to announce nothing at all.
  test "announces a thread whose first post was reported and approved before the announcement" do
    topic = create_topic("Release notes, see https://www.notebook.ai/changelog")
    @user.update!(site_administrator: true)
    report(topic.first_post)
    approve(topic.first_post.reload)
    assert topic.reload.approved?

    NotifyDiscordOfThreadJob.perform_now(topic.id)

    WebMock.assert_requested(:post, WEBHOOK_URL, times: 1)
  end

  test "waits for a reported first post to be approved before announcing" do
    topic = create_topic("Hello there")
    report(topic.first_post)

    NotifyDiscordOfThreadJob.perform_now(topic.id) # creation-time run, while it's in the queue
    WebMock.assert_not_requested(:post, WEBHOOK_URL)

    approve(topic.first_post.reload)
    NotifyDiscordOfThreadJob.perform_now(topic.id) # approval-time run
    WebMock.assert_requested(:post, WEBHOOK_URL, times: 1)
  end

  test "does not announce a thread again when its first post is reported and approved later" do
    topic = create_topic("Hello there")
    NotifyDiscordOfThreadJob.perform_now(topic.id)

    report(topic.first_post)
    approve(topic.first_post.reload)
    NotifyDiscordOfThreadJob.perform_now(topic.id)

    WebMock.assert_requested(:post, WEBHOOK_URL, times: 1)
  end

  test "a failed announcement can be retried" do
    topic = create_topic("Hello there")
    WebMock.stub_request(:post, WEBHOOK_URL).to_return(status: 500).then.to_return(status: 204)

    assert_raises(StandardError) { NotifyDiscordOfThreadJob.perform_now(topic.id) }
    assert_nil topic.reload.discord_announced_at

    NotifyDiscordOfThreadJob.perform_now(topic.id)
    assert topic.reload.discord_announced_at.present?
  end

  test "still runs jobs enqueued by older code with a second argument" do
    topic = create_topic("Hello there")

    NotifyDiscordOfThreadJob.perform_now(topic.id, true)

    WebMock.assert_requested(:post, WEBHOOK_URL, times: 1)
  end

  test "approving a thread's first post enqueues an announcement" do
    topic = create_topic("Hello there")
    report(topic.first_post)

    in_production do
      assert_enqueued_with(job: NotifyDiscordOfThreadJob, args: [topic.id]) do
        approve(topic.first_post.reload)
      end
    end
  end

  test "approving a reply doesn't enqueue an announcement" do
    topic = create_topic("Hello there")
    reply = topic.posts.create!(content: "A reply", user: @moderator, messageboard: @messageboard)
    report(reply)

    in_production do
      assert_no_enqueued_jobs(only: NotifyDiscordOfThreadJob) { approve(reply.reload) }
    end
  end
end
