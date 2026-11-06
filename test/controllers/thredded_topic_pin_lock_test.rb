require 'test_helper'

# Pinning (sticky) and locking forum topics is for moderators only.
class ThreddedTopicPinLockTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @author = users(:one)
    @moderator = users(:two)
    @author.update_columns(created_at: 2.days.ago)
    @moderator.update_columns(forum_moderator: true, created_at: 2.days.ago)
    @messageboard = Thredded::Messageboard.create!(name: 'General')

    form = Thredded::TopicForm.new(title: 'Hello there', content: 'First post', user: @author, messageboard: @messageboard)
    assert form.save, form.errors.full_messages.to_sentence
    @topic = form.topic.reload
  end

  test "moderators get lock and pin options on the new topic form" do
    sign_in @moderator
    get thredded.messageboard_topics_path(@messageboard)
    assert_response :success
    assert_select 'input[type=checkbox][name="topic[sticky]"]'
    assert_select 'input[type=checkbox][name="topic[locked]"]'
  end

  test "other users don't get lock and pin options on the new topic form" do
    sign_in @author
    get thredded.messageboard_topics_path(@messageboard)
    assert_response :success
    assert_select 'input[name="topic[sticky]"]', count: 0
    assert_select 'input[name="topic[locked]"]', count: 0
  end

  test "moderators can create a pinned, locked topic" do
    sign_in @moderator
    post thredded.messageboard_topics_path(@messageboard),
         params: { topic: { title: 'Read me first', content: 'Rules', sticky: '1', locked: '1' } }

    topic = Thredded::Topic.find_by!(title: 'Read me first')
    assert topic.sticky?
    assert topic.locked?
  end

  test "other users can't create a pinned or locked topic" do
    sign_in @author
    post thredded.messageboard_topics_path(@messageboard),
         params: { topic: { title: 'Look at me', content: 'Hi', sticky: '1', locked: '1' } }

    topic = Thredded::Topic.find_by!(title: 'Look at me')
    assert_not topic.sticky?
    assert_not topic.locked?
  end

  test "moderators can pin and lock an existing topic" do
    sign_in @moderator
    get thredded.edit_messageboard_topic_path(@messageboard, @topic)
    assert_response :success
    assert_select 'input[type=checkbox][name="topic[sticky]"]'

    patch thredded.messageboard_topic_path(@messageboard, @topic),
          params: { topic: { title: 'Hello there', messageboard_id: @messageboard.id, sticky: '1', locked: '1' } }

    @topic.reload
    assert @topic.sticky?
    assert @topic.locked?
  end

  test "authors can edit their topic but not pin or lock it" do
    sign_in @author
    patch thredded.messageboard_topic_path(@messageboard, @topic),
          params: { topic: { title: 'Renamed', messageboard_id: @messageboard.id, sticky: '1', locked: '1' } }

    @topic.reload
    assert_equal 'Renamed', @topic.title
    assert_not @topic.sticky?
    assert_not @topic.locked?
  end
end
