require 'test_helper'

class ForumFirstPostModerationTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @user         = users(:one)
    @other_user   = users(:two)
    @messageboard = Thredded::Messageboard.create!(name: "Test board")
  end

  def create_topic_with_post(user, content, title: "A topic")
    form = Thredded::TopicForm.new(
      title:        title,
      content:      content,
      user:         user,
      messageboard: @messageboard
    )
    assert form.save, "expected topic form to save"
    [form.topic, form.post]
  end

  test "first-ever post containing a link is held for moderation, along with its topic and author" do
    topic, post = create_topic_with_post(@user, "Check out https://spam.example.com for cheap stuff")

    assert post.pending_moderation?
    assert topic.reload.pending_moderation?
    assert @user.reload.thredded_user_detail.pending_moderation?
  end

  test "first-ever post without a link is approved as usual" do
    topic, post = create_topic_with_post(@user, "Hello everyone, happy to be here!")

    assert post.approved?
    assert topic.reload.approved?
    assert @user.reload.thredded_user_detail.approved?
  end

  test "posts with links from users with existing posts are approved as usual" do
    create_topic_with_post(@user, "My first post, no links here")
    topic, post = create_topic_with_post(@user, "Now a link: https://example.com", title: "Second topic")

    assert post.approved?
    assert topic.reload.approved?
  end

  test "held first post as a reply does not affect someone else's topic" do
    topic, _post = create_topic_with_post(@other_user, "A perfectly normal thread")

    reply = Thredded::Post.create!(
      content:      "Buy now at www.spam.example",
      user:         @user,
      postable:     topic,
      messageboard: @messageboard
    )

    assert reply.pending_moderation?
    assert topic.reload.approved?
    assert @user.reload.thredded_user_detail.pending_moderation?
  end

  test "subsequent posts by a held user are also held" do
    create_topic_with_post(@user, "First post with https://spam.example.com link")
    topic, post = create_topic_with_post(@user, "A follow-up with no links at all", title: "Second topic")

    assert post.pending_moderation?
    assert topic.reload.pending_moderation?
  end

  test "forum staff are exempt from first-post link moderation" do
    @user.update!(forum_moderator: true)
    _topic, post = create_topic_with_post(@user, "Announcement: https://notebook.ai/some/page")

    assert post.approved?
  end

  test "approving a held post from the moderation queue approves the topic and author" do
    topic, post = create_topic_with_post(@user, "Check out https://spam.example.com")
    moderator = @other_user
    moderator.update!(forum_moderator: true)

    Thredded::ModeratePost.run!(post: post, moderation_state: :approved, moderator: moderator)

    assert post.reload.approved?
    assert topic.reload.approved?
    assert @user.reload.thredded_user_detail.approved?
  end

  test "detects common link formats" do
    ["https://example.com", "http://example.com", "visit www.example.com now",
     "a [markdown link](https://example.com)"].each do |content|
      assert Thredded::Post.new(content: content).contains_link?, "expected link in: #{content}"
    end

    ["no links here", "just talking about wwwater", "parentheses (like these)"].each do |content|
      assert_not Thredded::Post.new(content: content).contains_link?, "expected no link in: #{content}"
    end
  end

  test "moderators are pinged on Discord when a post is held" do
    assert_enqueued_with(job: NotifyDiscordOfPendingPostJob) do
      create_topic_with_post(@user, "Spam here: https://spam.example.com")
    end
  end

  test "moderators are only pinged once while a user has posts in the queue" do
    create_topic_with_post(@user, "Spam here: https://spam.example.com")

    assert_no_enqueued_jobs(only: NotifyDiscordOfPendingPostJob) do
      create_topic_with_post(@user, "More posts while pending", title: "Second topic")
    end
  end

  test "moderators are pinged when an approved post is reported" do
    _topic, post = create_topic_with_post(@user, "A perfectly normal first post")
    assert post.approved?

    assert_enqueued_with(job: NotifyDiscordOfPendingPostJob) do
      post.update!(moderation_state: :pending_moderation)
    end
  end
end
