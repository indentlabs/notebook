require 'test_helper'

# Starting a forum topic shares it to the author's stream, so topics show up
# anywhere shares do, next to content pages.
class ForumTopicSharesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @author = users(:one)
    @reader = users(:two)
    @author.update_columns(created_at: 2.days.ago)
    UserFollowing.create!(user_id: @reader.id, followed_user_id: @author.id)
    @messageboard = Thredded::Messageboard.create!(name: 'General')

    form = Thredded::TopicForm.new(title: 'TOPICTITLE', content: 'First post', user: @author, messageboard: @messageboard)
    assert form.save, form.errors.full_messages.to_sentence
    @topic = form.topic.reload
    @share = ContentPageShare.find_by!(content_page_type: 'Thredded::Topic', content_page_id: @topic.id)

    sign_in @reader
  end

  test "the activity stream shows forum topics" do
    get stream_path

    assert_response :success
    assert_includes response.body, 'TOPICTITLE'
  end

  test "the activity stream hides topics a moderator blocked" do
    @topic.update!(moderation_state: :blocked)

    get stream_path

    assert_response :success
    assert_includes response.body, 'This page is no longer public'
  end

  test "a topic's share page renders" do
    get user_content_page_share_path(@author, @share)

    assert_response :success
  end

  test "the author's profile renders their topic" do
    get user_path(@author)

    assert_response :success
    assert_includes response.body, 'TOPICTITLE'
  end
end
