require 'test_helper'

# What an account that hasn't confirmed its email address sees and can do (see User#can_publish?).
class EmailConfirmationGatesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

  NOTICE = 'Confirm your email address to'.freeze

  setup do
    @author = users(:one)
    @author.update_columns(created_at: 2.days.ago)
    @newcomer = User.create!(email: 'newcomer@example.com', password: 'password')

    @messageboard = Thredded::Messageboard.create!(name: 'General')
    form = Thredded::TopicForm.new(title: 'Hello there', content: 'First post', user: @author, messageboard: @messageboard)
    assert form.save, form.errors.full_messages.to_sentence
    @topic = form.topic.reload
  end

  test "signing up signs you in and sends a confirmation email" do
    assert_enqueued_emails 1 do
      post user_registration_path, params: { user: { email: 'brand-new@example.com', password: 'password', password_confirmation: 'password' } }
    end

    user = User.find_by!(email: 'brand-new@example.com')
    assert_not user.confirmed?
    follow_redirect!
    assert_response :success
    assert_equal user.id, controller.current_user&.id
  end

  test "following the emailed link confirms the account" do
    token = @newcomer.confirmation_token

    get user_confirmation_path(confirmation_token: token)

    assert @newcomer.reload.confirmed?
  end

  test "unconfirmed accounts can read a topic but are told why they can't reply" do
    sign_in @newcomer

    get thredded.messageboard_topic_path(@messageboard, @topic)

    assert_response :success
    assert_includes response.body, 'First post'
    assert_includes response.body, "#{NOTICE} reply on the forums"
    assert_select '.reply-form-section', count: 0
  end

  test "unconfirmed accounts can't reply to topics" do
    sign_in @newcomer

    assert_no_difference -> { Thredded::Post.count } do
      post thredded.messageboard_topic_posts_path(@messageboard, @topic), params: { post: { content: 'Spam' } }
    end
    assert_response :forbidden
    assert_includes response.body, 'Please confirm your email address first'
  end

  test "unconfirmed accounts can't start topics" do
    sign_in @newcomer

    get thredded.messageboard_topics_path(@messageboard)
    assert_response :success
    assert_includes response.body, "#{NOTICE} start new topics"

    assert_no_difference -> { Thredded::Topic.count } do
      post thredded.messageboard_topics_path(@messageboard), params: { topic: { title: 'Buy now', content: 'Spam' } }
    end
    assert_response :forbidden
  end

  test "unconfirmed accounts can't start private conversations" do
    sign_in @newcomer

    get thredded.private_topics_path
    assert_response :success
    assert_includes response.body, "#{NOTICE} start new conversations"

    assert_no_difference -> { Thredded::PrivateTopic.count } do
      post thredded.private_topics_path, params: { private_topic: { title: 'Hi', content: 'Spam', user_ids: [@author.id.to_s] } }
    end
    assert_response :forbidden
  end

  test "confirmed accounts can still reply" do
    sign_in users(:two)

    get thredded.messageboard_topic_path(@messageboard, @topic)
    assert_select '.reply-form-section', count: 1
    assert_not_includes response.body, NOTICE

    assert_difference -> { Thredded::Post.count }, 1 do
      post thredded.messageboard_topic_posts_path(@messageboard, @topic), params: { post: { content: 'A real reply' } }
    end
  end

  test "the privacy panel tells unconfirmed owners why they can't go public" do
    character = Character.create!(user: @newcomer, name: 'Hidden', privacy: 'private')
    sign_in @newcomer

    get edit_character_path(character)

    assert_response :success
    assert_includes response.body, "#{NOTICE} make this character public"
    assert_select '#privacy-settings-form input[type=radio][value=public][disabled]'
  end

  test "making a page public explains the failure to unconfirmed owners" do
    character = Character.create!(user: @newcomer, name: 'Hidden', privacy: 'private')
    sign_in @newcomer

    patch character_path(character), params: { character: { privacy: 'public' } }, as: :json

    assert_response :unprocessable_entity
    assert_equal [RequiresConfirmedEmailToPublish::CONFIRMATION_REQUIRED_ERROR], response.parsed_body['privacy']
    assert_equal 'private', character.reload.privacy
  end

  test "commenting on a share explains the failure to unconfirmed accounts" do
    page  = Character.create!(user: @author, name: 'Shown', privacy: 'public')
    share = ContentPageShare.create!(user: @author, content_page: page, shared_at: Time.current)
    sign_in @newcomer

    get user_content_page_share_path(@author, share)
    assert_includes response.body, "#{NOTICE} leave comments"

    assert_no_difference -> { ShareComment.count } do
      post share_comments_path, params: { share_comment: { content_page_share_id: share.id, message: 'Spam' } },
                                headers: { 'HTTP_REFERER' => user_content_page_share_url(@author, share) }
    end
    assert_redirected_to user_content_page_share_url(@author, share)
    assert_equal User::CONFIRM_EMAIL_TO_PUBLISH_MESSAGE, flash[:alert]
  end

  test "account settings offer to resend the confirmation link, and send you back there" do
    sign_in @newcomer

    get edit_user_registration_path
    assert_includes response.body, NOTICE
    assert_select "form[action='#{user_confirmation_path}'] input[name='user[email]'][value='newcomer@example.com']"

    assert_enqueued_emails 1 do
      post user_confirmation_path, params: { user: { email: @newcomer.email } },
                                   headers: { 'HTTP_REFERER' => edit_user_registration_url }
    end
    assert_redirected_to edit_user_registration_path
  end

  test "confirmed accounts don't see the notice in account settings" do
    sign_in users(:two)

    get edit_user_registration_path

    assert_response :success
    assert_not_includes response.body, NOTICE
  end
end
