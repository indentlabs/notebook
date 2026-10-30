require 'test_helper'

# The plaintext, IRC log and save views of a forum topic have to follow the same
# rules as the forum itself.
class ThreddedProxyAccessTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  BLOCKED = 'BLOCKEDPOST'
  VISIBLE = 'VISIBLEPOST'

  setup do
    @author = users(:one)
    @reader = users(:two)
    @author.update_columns(created_at: 2.days.ago)
    @messageboard = Thredded::Messageboard.create!(name: 'General')

    form = Thredded::TopicForm.new(title: 'Hello there', content: VISIBLE, user: @author, messageboard: @messageboard)
    assert form.save, form.errors.full_messages.to_sentence
    @topic = form.topic.reload
    @blocked_post = @topic.posts.create!(content: BLOCKED, user: @author, messageboard: @messageboard)
    @blocked_post.update!(moderation_state: :blocked)
    sign_in @reader
  end

  test "the plaintext view leaves out blocked posts" do
    get plaintext_topic_path(@topic.slug)

    assert_response :success
    assert_includes response.body, VISIBLE
    assert_not_includes response.body, BLOCKED
  end

  test "the IRC log view leaves out blocked posts" do
    get irc_log_topic_path(@topic.slug)

    assert_response :success
    assert_includes response.body, VISIBLE
    assert_not_includes response.body, BLOCKED
  end

  test "saving a topic leaves out blocked posts" do
    get documentize_topic_path(@topic.slug)

    document = @reader.documents.order(:id).last
    assert_includes document.body, VISIBLE
    assert_not_includes document.body, BLOCKED
  end

  test "these views don't show a blocked topic" do
    @topic.update!(moderation_state: :blocked)

    get plaintext_topic_path(@topic.slug)
    assert_redirected_to root_path
    assert_not_includes response.body, VISIBLE

    sign_in @reader
    get irc_log_topic_path(@topic.slug)
    assert_redirected_to root_path

    sign_in @reader
    assert_no_difference -> { Document.count } do
      get documentize_topic_path(@topic.slug)
    end
  end

  test "these views cope with a topic that doesn't exist" do
    get plaintext_topic_path('no-such-topic')

    assert_redirected_to root_path
  end

  test "saving a topic only links pages the reader can read" do
    secret = Character.create!(user: @author, name: 'Secret', privacy: 'private')
    public = Character.create!(user: @author, name: 'Public', privacy: 'public')
    form = Thredded::TopicForm.new(
      title: 'With links', content: "[[Character-#{secret.id}]] and [[Character-#{public.id}]]", user: @author, messageboard: @messageboard
    )
    assert form.save, form.errors.full_messages.to_sentence

    get documentize_topic_path(form.topic.reload.slug)

    assert_not DocumentEntity.exists?(entity_type: 'Character', entity_id: secret.id)
    assert DocumentEntity.exists?(entity_type: 'Character', entity_id: public.id)
  end

  test "saving a topic only links pages the reader can read through a link too" do
    secret = Character.create!(user: @author, name: 'Secret', privacy: 'private')
    form = Thredded::TopicForm.new(
      title: 'With links', content: "See https://www.notebook.ai/plan/characters/#{secret.id}", user: @author, messageboard: @messageboard
    )
    assert form.save, form.errors.full_messages.to_sentence
    form.post.update!(moderation_state: :approved)
    form.topic.update!(moderation_state: :approved)

    get documentize_topic_path(form.topic.reload.slug)

    assert_response :redirect
    assert_not DocumentEntity.exists?(entity_type: 'Character', entity_id: secret.id)
  end
end
