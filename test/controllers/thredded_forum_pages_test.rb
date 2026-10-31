require 'test_helper'

# Smoke tests for the forum moderation tabs and forum pagination.
class ThreddedForumPagesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @author = users(:one)
    @moderator = users(:two)
    @author.update_columns(created_at: 2.days.ago)
    @moderator.update_columns(forum_moderator: true)
    @messageboard = Thredded::Messageboard.create!(name: 'General')

    form = Thredded::TopicForm.new(title: 'Hello there', content: 'First post', user: @author, messageboard: @messageboard)
    assert form.save, form.errors.full_messages.to_sentence
    @topic = form.topic.reload
    @topic.posts.create!(content: 'A reply', user: @author, messageboard: @messageboard)

    sign_in @moderator
  end

  {
    pending:  :pending_moderation_path,
    history:  :moderation_history_path,
    activity: :moderation_activity_path,
    users:    :users_moderation_path
  }.each do |tab, route|
    test "the moderation #{tab} tab renders" do
      get thredded.public_send(route)
      assert_response :success
    end
  end

  test "the activity tab renders posts from deleted users" do
    @topic.posts.last.update_columns(user_id: nil)

    get thredded.moderation_activity_path
    assert_response :success
  end

  test "the moderation tabs skip posts whose topic is gone" do
    orphan = Thredded::TopicForm.new(title: 'Gone', content: 'ORPHANPOST', user: @author, messageboard: @messageboard)
    assert orphan.save
    Thredded::Topic.where(id: orphan.topic.id).delete_all

    get thredded.moderation_activity_path
    assert_response :success
    assert_not_includes response.body, 'ORPHANPOST'

    get thredded.user_moderation_path(@author.id)
    assert_response :success
  end

  test "the activity tab renders the second page" do
    30.times { |i| @topic.posts.create!(content: "Reply #{i}", user: @author, messageboard: @messageboard) }

    get thredded.moderation_activity_path(page: 2)
    assert_response :success
    assert_select 'nav.forum-pagination'
  end

  test "topics with several pages render mobile-friendly pagination" do
    30.times { |i| @topic.posts.create!(content: "Reply #{i}", user: @author, messageboard: @messageboard) }

    get thredded.messageboard_topic_path(@messageboard, @topic)
    assert_response :success
    assert_select 'nav.forum-pagination', minimum: 1
    assert_select 'nav.forum-pagination', text: /Page.*of\s+\d+/m
    assert_select "nav.forum-pagination select option[selected]", text: "1"
    assert_select "nav.forum-pagination select[data-total-pages=\"2\"]"
    assert_select "nav.forum-pagination select[data-page-url-template$=\"/page-#{ForumPaginationHelper::PAGE_NUMBER_PLACEHOLDER}\"]"
  end
end
