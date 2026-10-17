require 'test_helper'
require 'minitest/mock'

class ThreddedAutomoderationTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @user.update_columns(created_at: 2.days.ago)
    @messageboard = Thredded::Messageboard.create!(name: 'General')
  end

  def create_topic(content, user: @user, title: 'Hello there')
    form = Thredded::TopicForm.new(title: title, content: content, user: user, messageboard: @messageboard)
    assert form.save, form.errors.full_messages.to_sentence
    [form.topic.reload, form.post.reload]
  end

  def reply(topic, content, user: @user)
    topic.posts.create!(content: content, user: user, messageboard: @messageboard)
  end

  test "holds a new account's first topic for moderation when it contains a link" do
    topic, post = create_topic('Check out https://spam.example')

    assert post.pending_moderation?
    assert topic.pending_moderation?
    assert_includes Thredded::Post.pending_moderation, post
  end

  test "holds a new account's first reply when it contains a link" do
    topic, _post = create_topic('Hi everyone!', user: users(:two))
    post = reply(topic, 'buy now at cheap-pills.shop')

    assert post.pending_moderation?
    assert topic.reload.approved?
  end

  test "does not hold a new account's first post without a link" do
    topic, post = create_topic('Hi everyone, excited to be here!')

    assert post.approved?
    assert topic.approved?
  end

  test "does not hold a link in a new account's second post" do
    topic, _post = create_topic('Hi everyone!')
    post = reply(topic, 'Here is my blog: www.example.com')

    assert post.approved?
  end

  test "does not hold a link in an older account's first post" do
    @user.update_columns(created_at: 1.year.ago)
    topic, post = create_topic('Check out https://example.com')

    assert post.approved?
    assert topic.approved?
  end

  test "Discord is not notified about a held topic" do
    topic, _post = create_topic('Check out https://spam.example')

    Discordrb::Webhooks::Client.stub(:new, ->(*) { flunk 'should not post to Discord' }) do
      NotifyDiscordOfThreadJob.perform_now(topic.id)
    end
  end
end
