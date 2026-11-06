require 'test_helper'

# Accounts have to confirm their email address before they can put anything in front of other
# people (see User#can_publish?). Everything else works the same whether or not they have.
class EmailConfirmationTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  setup do
    @confirmed   = users(:one)
    @unconfirmed = User.create!(email: 'newcomer@example.com', password: 'password')
  end

  test "accounts from before confirmations existed are confirmed" do
    assert @confirmed.confirmed?
    assert @confirmed.can_publish?
  end

  test "new accounts start unconfirmed but can still sign in" do
    assert_not @unconfirmed.confirmed?
    assert_not @unconfirmed.can_publish?
    assert @unconfirmed.active_for_authentication?
  end

  test "new accounts are sent a confirmation email from the background queue" do
    assert_enqueued_emails 1 do
      User.create!(email: 'another-newcomer@example.com', password: 'password')
    end
    assert_enqueued_with(queue: 'notifications')

    perform_enqueued_jobs
    mail = ActionMailer::Base.deliveries.last
    assert_equal ['another-newcomer@example.com'], mail.to
    assert_includes mail.body.to_s, 'Confirm my email address'
  end

  test "confirming lets an account publish" do
    @unconfirmed.confirm
    assert @unconfirmed.reload.can_publish?
  end

  test "changing a confirmed account's email address doesn't take away publishing" do
    @confirmed.update!(email: 'changed@example.com')

    assert @confirmed.reload.pending_reconfirmation?
    assert @confirmed.can_publish?
  end

  test "confirmation details aren't in a user's JSON" do
    @unconfirmed.update_columns(unconfirmed_email: 'secret-new@example.com')
    json = @unconfirmed.to_json

    assert_not_includes json, @unconfirmed.confirmation_token
    assert_not_includes json, 'secret-new@example.com'
  end

  test "unconfirmed accounts can't post in any messageboard" do
    Thredded::Messageboard.create!(name: 'General')

    assert_empty @unconfirmed.thredded_can_write_messageboards
    assert_equal Thredded::Messageboard.count, @confirmed.thredded_can_write_messageboards.count
  end

  test "unconfirmed accounts can't make pages public" do
    character = Character.create!(user: @unconfirmed, name: 'Hidden', privacy: 'private')

    assert_not character.update(privacy: 'public')
    assert_includes character.errors[:privacy], RequiresConfirmedEmailToPublish::CONFIRMATION_REQUIRED_ERROR
    assert_equal 'private', character.reload.privacy
  end

  test "unconfirmed accounts can't create public pages" do
    character = Character.new(user: @unconfirmed, name: 'Loud', privacy: 'public')

    assert_not character.save
  end

  test "unconfirmed accounts can still edit their private pages" do
    character = Character.create!(user: @unconfirmed, name: 'Hidden', privacy: 'private')

    assert character.update(name: 'Renamed')
  end

  test "pages that are already public can still be edited if their owner hasn't confirmed" do
    character = Character.create!(user: @unconfirmed, name: 'Old', privacy: 'private')
    character.update_columns(privacy: 'public')

    assert character.reload.update(name: 'Still public')
  end

  test "confirmed accounts can make pages public" do
    character = Character.create!(user: @confirmed, name: 'Shown', privacy: 'private')

    assert character.update(privacy: 'public')
  end

  test "every kind of page with a privacy setting needs a confirmed owner to go public" do
    pages = [
      Universe.create!(user: @unconfirmed, name: 'World'),
      Document.create!(user: @unconfirmed, title: 'Draft'),
      Book.create!(user: @unconfirmed, name: 'Novel'),
      Timeline.create!(user: @unconfirmed, name: 'History'),
      PageCollection.create!(user: @unconfirmed, title: 'Favorites', privacy: 'private')
    ]

    pages.each do |page|
      assert_not page.update(privacy: 'public'), "#{page.class.name} was made public by an unconfirmed owner"
    end
  end

  test "unconfirmed accounts can't share to the stream" do
    character = Character.create!(user: @unconfirmed, name: 'Hidden', privacy: 'private')
    share = ContentPageShare.new(user: @unconfirmed, content_page: character, shared_at: Time.current)

    assert_not share.save
    assert_includes share.errors[:base], User::CONFIRM_EMAIL_TO_PUBLISH_MESSAGE
  end

  test "unconfirmed accounts can't comment on shares" do
    page  = Character.create!(user: @confirmed, name: 'Shown', privacy: 'public')
    share = ContentPageShare.create!(user: @confirmed, content_page: page, shared_at: Time.current)

    assert_not ShareComment.new(user: @unconfirmed, content_page_share: share, message: 'Hi').save
    assert ShareComment.new(user: users(:two), content_page_share: share, message: 'Hi').save
  end

  test "unconfirmed accounts can't submit pages to public collections" do
    collection = PageCollection.create!(user: @confirmed, title: 'Open', privacy: 'public', page_types: ['Character'])
    character  = Character.create!(user: @unconfirmed, name: 'Hidden', privacy: 'private')

    submission = PageCollectionSubmission.new(page_collection: collection, content: character, user: @unconfirmed, submitted_at: Time.current)
    assert_not submission.save
    assert_equal 'private', character.reload.privacy
  end
end
